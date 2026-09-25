import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/theme/accent_backdrop.dart';
import 'package:memini/core/theme/tokens.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  /// The first colour of the diagonal wash — the accent, bled into the page.
  Future<Color> washOf(WidgetTester tester, {required AppAccent accent}) async {
    await tester.pumpWidget(
      await harness(
        const Scaffold(body: SizedBox.shrink()),
        database: db,
        accent: accent,
      ),
    );
    await tester.pump();

    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AccentBackdrop),
        matching: find.byType(DecoratedBox),
      ).first,
    );

    return ((box.decoration as BoxDecoration).gradient! as LinearGradient)
        .colors
        .first;
  }

  testWidgets('the page is washed with the accent that was chosen', (
    tester,
  ) async {
    final brass = await washOf(tester, accent: AppAccent.brass);
    await unmount(tester);
    final violet = await washOf(tester, accent: AppAccent.violet);

    expect(brass, isNot(violet), reason: 'the page follows the accent');
    await unmount(tester);
  });

  testWidgets('the wash is the page with a little accent in it, not the '
      'accent', (tester) async {
    final wash = await washOf(tester, accent: AppAccent.violet);

    // Opaque, and much closer to the page than to the accent it carries:
    // a background that competes with the entries is one you turn off.
    expect(wash.a, 1.0);
    final distance =
        (wash.r - MeminiColors.paper.r).abs() +
        (wash.g - MeminiColors.paper.g).abs() +
        (wash.b - MeminiColors.paper.b).abs();
    expect(distance, lessThan(0.25));
    await unmount(tester);
  });

  testWidgets('every screen sits on it rather than covering it', (
    tester,
  ) async {
    await tester.pumpWidget(
      await harness(const Scaffold(body: SizedBox.shrink()), database: db),
    );
    await tester.pump();

    // A scaffold that brought its own colour would cut a rectangle out of
    // the wash, which is the whole reason the theme stopped giving it one.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor,
      Colors.transparent,
    );
    await unmount(tester);
  });
}
