import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/time/clock.dart';
import 'package:memini/features/home/presentation/home_providers.dart';
import 'package:memini/features/home/presentation/widgets/activity_grid_card.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  /// Pumps the grid inside a box of exactly [width], which is what it
  /// measures itself against.
  Future<void> pump(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width + 200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      await harness(
        Scaffold(
          body: Center(
            child: SizedBox(width: width, child: const ActivityGridCard()),
          ),
        ),
        database: db,
        overrides: [
          clockProvider.overrideWithValue(() => DateTime(2026, 9, 25)),
        ],
      ),
    );
    await tester.pump();
  }

  /// The block of squares, which is the thing that has to fill the width.
  Rect grid(WidgetTester tester) =>
      tester.getRect(find.byKey(ActivityGridCard.squaresKey));

  /// One square's side, taken from the first cell in the block.
  double side(WidgetTester tester) =>
      grid(tester).height / 7 - ActivityGridCard.gap;

  testWidgets('a wide window gets a year, drawn edge to edge', (tester) async {
    await pump(tester, 1200);

    // It used to stop at 26 columns of 20px and leave the rest of a desktop
    // empty beside it.
    expect(grid(tester).width, closeTo(1200, 1));
    expect(find.text('Last 53 weeks'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a phone gets fewer weeks rather than smaller squares', (
    tester,
  ) async {
    await pump(tester, 360);

    // Half a year at this width meant 7px squares; a season at a size you
    // can see says more.
    expect(side(tester), greaterThan(14));
    expect(grid(tester).width, closeTo(360, 1));
    expect(find.text('Last 53 weeks'), findsNothing);
    await unmount(tester);
  });

  testWidgets('it never shows more than a year, however wide the window', (
    tester,
  ) async {
    await pump(tester, 2400);

    expect(find.text('Last $activityWeeksMax weeks'), findsOneWidget);
    // Nor does it grow the squares into tiles to fill the room.
    expect(side(tester), lessThanOrEqualTo(26));
    await unmount(tester);
  });
}
