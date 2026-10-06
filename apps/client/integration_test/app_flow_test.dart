// The app driven end to end, on the real thing: its own database on disk,
// its own preferences, its own router. The widget tests build one screen
// with everything faked around it, so nothing there would notice a database
// that fails to open on a real platform, a migration that throws on first
// launch, or a route that no longer resolves.
//
//   flutter test integration_test -d linux
//
// On a headless machine, wrap it: `xvfb-run -a flutter test integration_test
// -d linux`. The Linux shell is a real GTK application and wants a display
// even when nobody is watching.
//
// The same flow runs in a browser through `tool/test_web.sh`.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memini/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import 'support/stored_bytes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Onboarding done and the disclaimer accepted, so the app opens on itself
    // rather than on the wizard; otherwise this drives the first-run flow
    // instead of the app.
    SharedPreferences.setMockInitialValues({
      'onboarding.tutorial_seen': true,
      'onboarding.disclaimer_accepted': true,
      'onboarding.backup_notice_accepted': true,
      'settings.locale': 'en',
    });
  });

  testWidgets('boots into the app and moves between sections', (tester) async {
    // Phone-sized on purpose: the shell shows a rail on a wide window and a
    // bottom bar on a narrow one, and this walks the bottom bar. The desktop
    // window these run in would otherwise pick the other layout.
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Awaited: main() resolves preferences before it calls runApp, so without
    // this the first pump finds an empty tree.
    await app.main();
    await tester.pumpAndSettle();

    // Getting this far already covers what a widget test cannot: the database
    // opened, preferences resolved, and the router settled on a route.
    expect(find.byType(Scaffold), findsWidgets);

    final destinations = find.byType(NavigationDestination);
    expect(
      destinations,
      findsWidgets,
      reason: 'the shell should offer its sections',
    );

    // Walking them is what catches a route that stopped resolving after a
    // refactor — the analyser never sees a broken navigation path.
    for (var i = 0; i < 2; i++) {
      await tester.tap(destinations.at(i));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'section $i should open without throwing',
      );
    }
  });

  testWidgets('a new room reaches durable storage', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await app.main();
    await tester.pumpAndSettle();

    final name = 'Room ${DateTime.now().microsecondsSinceEpoch}';
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Escape rooms'), findsWidgets);
    await tester.tap(find.text('Add room'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), name);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text(name), findsWidgets);

    // On the web the list above is answered by the drift worker, which keeps
    // the store in memory and writes it to IndexedDB only when told to. What
    // the worker has not written dies with it when the last tab closes, so
    // the room has to be in IndexedDB itself, not just on screen. Nothing is
    // written after the save, so no later write can copy it out by accident.
    expect(
      await pumpUntilStored(tester, name),
      isTrue,
      reason: 'the new room never reached IndexedDB',
    );
  });
}

/// Whether [text] reaches what the browser has durably stored before
/// [timeout]. Always true off the web, where writes go straight to a file.
Future<bool> pumpUntilStored(
  WidgetTester tester,
  String text, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final needle = utf8.encode(text);
  final deadline = DateTime.now().add(timeout);
  do {
    final bytes = await browserStoredBytes('memini');
    if (bytes == null || _contains(bytes, needle)) return true;
    await tester.pump(const Duration(milliseconds: 200));
  } while (DateTime.now().isBefore(deadline));
  return false;
}

bool _contains(List<int> haystack, List<int> needle) {
  outer:
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
