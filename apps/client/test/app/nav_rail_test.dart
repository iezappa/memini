import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/nav_rail.dart';
import 'package:memini/core/database/app_database.dart';

import '../support/harness.dart';

void main() {
  late AppDatabase db;
  late List<int> tapped;

  setUp(() {
    db = memoryDatabase();
    tapped = [];
  });
  tearDown(() => db.close());

  const destinations = <NavDestination>[
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.restaurant_outlined, Icons.restaurant, 'Places I ate'),
    (Icons.insights_outlined, Icons.insights, 'Stats'),
  ];

  Future<void> pump(WidgetTester tester, {int selected = 0}) async {
    await tester.pumpWidget(
      await harness(
        Scaffold(
          body: NavRail(
            destinations: destinations,
            selectedIndex: selected,
            onSelected: tapped.add,
          ),
        ),
        database: db,
      ),
    );
    await tester.pump();
  }

  testWidgets('it is icons, not words', (tester) async {
    await pump(tester);

    // The phone's bar has hidden its labels since the icons were chosen.
    // The rail used to print them under every icon, which is the half of
    // the app that disagreed with the other half.
    expect(find.text('Places I ate'), findsNothing);
    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('every destination still says its name, out loud', (
    tester,
  ) async {
    await pump(tester);

    for (final (_, _, label) in destinations) {
      expect(find.byTooltip(label), findsOneWidget, reason: label);
    }
    await unmount(tester);
  });

  testWidgets('the section you are in is the filled one', (tester) async {
    await pump(tester, selected: 1);

    // Filled, and drawn with the icon a selected destination carries.
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_outlined), findsNothing);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tapping one asks for that branch', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Stats'));
    await tester.pump();

    expect(tapped, [2]);
    await unmount(tester);
  });

  testWidgets('every target is one a finger can hit', (tester) async {
    await pump(tester);

    for (final (_, _, label) in destinations) {
      final size = tester.getSize(find.byTooltip(label));
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
    }
    await unmount(tester);
  });

  group('the gear at the foot', () {
    Future<void> pumpWithFooter(
      WidgetTester tester, {
      bool selected = false,
      VoidCallback? onTap,
    }) async {
      await tester.pumpWidget(
        await harness(
          Scaffold(
            body: NavRail(
              destinations: destinations,
              selectedIndex: 0,
              onSelected: tapped.add,
              footer: (Icons.settings_outlined, Icons.settings, 'Settings'),
              footerSelected: selected,
              onFooterSelected: onTap,
            ),
          ),
          database: db,
        ),
      );
      await tester.pump();
    }

    testWidgets('sits under a rule, because it is not a section', (
      tester,
    ) async {
      await pumpWithFooter(tester);

      expect(find.byTooltip('Settings'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      // Below every section, which is what makes it read as apart from them.
      expect(
        tester.getCenter(find.byTooltip('Settings')).dy,
        greaterThan(tester.getCenter(find.byTooltip('Stats')).dy),
      );
      await unmount(tester);
    });

    testWidgets('fills like any other when that is where you are', (
      tester,
    ) async {
      await pumpWithFooter(tester, selected: true);

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
      await unmount(tester);
    });

    testWidgets('opens settings', (tester) async {
      var opened = false;
      await pumpWithFooter(tester, onTap: () => opened = true);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pump();

      expect(opened, isTrue);
      await unmount(tester);
    });

    testWidgets('a rail without one shows no rule', (tester) async {
      await pump(tester);

      expect(find.byType(Divider), findsNothing);
      await unmount(tester);
    });
  });

  testWidgets('a short window scrolls rather than hiding a section', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pump(tester);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'nothing overflows');
    await unmount(tester);
  });
}
