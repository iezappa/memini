import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/dining/data/drift_meal_repository.dart';
import 'package:memini/features/dining/domain/meal.dart';
import 'package:memini/features/dining/domain/meal_repository.dart';
import 'package:memini/features/dining/presentation/meal_detail_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftMealRepository entries;

  setUp(() {
    db = memoryDatabase();
    entries = DriftMealRepository(db);
  });
  tearDown(() => db.close());

  Future<Meal> log() => entries.create(
    MealDraft(
      title: 'Don Julio',
      happenedOn: DateTime(2026, 5, 2),
      dish: 'Ojo de bife',
      review: 'Worth the queue.',
    ),
  );

  Future<void> pumpDetail(WidgetTester tester, Meal entry) =>
      pumpPushed(tester, MealDetailScreen(mealId: entry.id), database: db);

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
  }

  testWidgets('shows what was logged', (tester) async {
    await pumpDetail(tester, await log());

    expect(find.text('Don Julio'), findsWidgets);
    expect(find.text('Worth the queue.'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets(
    'names the entry it would destroy, and warns it cannot be undone',
    (tester) async {
      await pumpDetail(tester, await log());

      await tapDelete(tester);

      expect(
        find.text('Delete "Don Julio"? This cannot be undone.'),
        findsOneWidget,
      );

      await unmount(tester);
    },
  );

  testWidgets('leaves the entry alone when the delete is cancelled', (
    tester,
  ) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // There is no server and no undo: a delete that fires on a cancel takes
    // the entry with it for good.
    expect(await entries.list(const MealFilter()), hasLength(1));

    await unmount(tester);
  });

  testWidgets('deletes the entry once the delete is confirmed', (tester) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await entries.list(const MealFilter()), isEmpty);

    await unmount(tester);
  });
}
