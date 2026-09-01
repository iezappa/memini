import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
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
