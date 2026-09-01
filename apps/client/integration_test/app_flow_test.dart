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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memini/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Onboarding done and the disclaimer accepted, so the app opens on itself
    // rather than on the wizard; otherwise this drives the first-run flow
    // instead of the app.
    SharedPreferences.setMockInitialValues({
      'onboarding.tutorial_seen': true,
      'onboarding.disclaimer_accepted': true,
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
}
