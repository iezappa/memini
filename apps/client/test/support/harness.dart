import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/security/data/pin_service.dart';
import 'package:memini/core/theme/theme.dart';
import 'package:memini/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots a widget against an in-memory database and empty preferences, with
/// the real theme and localizations so tests see what the user sees.
Future<Widget> harness(
  Widget child, {
  required AppDatabase database,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      databaseProvider.overrideWithValue(database),
      ...overrides,
    ],
    child: MaterialApp(
      theme: MeminiTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

AppDatabase memoryDatabase() {
  // Each test opens its own database and closes it in tearDown; the overlap
  // during teardown is what triggers Drift's multiple-instance warning.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Tears the tree down inside the test body.
///
/// Cancelling a Drift query stream schedules a zero-duration timer, and the
/// test binding asserts no timer is pending once the tree is disposed — so the
/// disposal has to happen while there are still frames left to pump.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Tearing down a Drift query stream schedules zero-duration timers, and each
  // one can schedule the next; the binding asserts none are pending once the
  // tree is gone. A handful of frames drains the chain, and the one-second
  // step also outlasts any SnackBar left on screen.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

/// Gives the test a tall window so a `ListView` builds its whole child list.
///
/// A list only builds what fits on screen, so anything below the fold — the
/// save button at the bottom of a form, the last sections of a settings page —
/// simply does not exist for a finder, and the failure reads as "found 0
/// widgets" rather than "you cannot see it yet". Widening the window is the
/// honest fix; scrolling first would test the scroll, not the screen.
void useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Pumps a form screen behind a route, the way the app reaches it.
///
/// Forms end with `Navigator.pop`, so mounting one as `home` would pop the
/// only route there is. Pushing it from a trivial first screen keeps the save
/// path the same as in production.
Future<void> pumpPushed(
  WidgetTester tester,
  Widget screen, {
  required AppDatabase database,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) async {
  useTallSurface(tester);
  await tester.pumpWidget(
    await harness(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<bool>(builder: (_) => screen)),
            child: const Text('open'),
          ),
        ),
      ),
      database: database,
      locale: locale,
      overrides: overrides,
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Form fields are labelled, not keyed, so the label is how a user finds them
/// and how a test should too.
Finder fieldLabelled(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(TextField));

Future<void> fillField(WidgetTester tester, String label, String value) async {
  await tester.enterText(fieldLabelled(label).first, value);
  await tester.pump();
}

/// Both the app bar and the foot of every form offer Save; the button at the
/// bottom is the one a finger actually reaches.
Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Save'));
  await tester.pumpAndSettle();
}

/// The keychain, in memory.
///
/// The real one is a platform channel, so anything that touches the PIN needs
/// this to be testable at all.
class InMemorySecureStore implements SecureStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
