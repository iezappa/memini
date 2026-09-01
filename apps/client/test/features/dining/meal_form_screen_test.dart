import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/dining/data/drift_meal_repository.dart';
import 'package:memini/features/dining/domain/meal.dart';
import 'package:memini/features/dining/domain/meal_repository.dart';
import 'package:memini/features/dining/presentation/meal_form_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftMealRepository meals;

  setUp(() {
    db = memoryDatabase();
    meals = DriftMealRepository(db);
  });
  tearDown(() => db.close());

  Future<void> pumpForm(WidgetTester tester, {Meal? meal}) =>
      pumpPushed(tester, MealFormScreen(meal: meal), database: db);

  testWidgets('will not save a meal with no place', (tester) async {
    await pumpForm(tester);

    await tapSave(tester);

    expect(find.text('The place needs a name'), findsOneWidget);
    expect(await meals.list(const MealFilter()), isEmpty);

    await unmount(tester);
  });

  testWidgets('reads a price written with a comma', (tester) async {
    await pumpForm(tester);

    await fillField(tester, 'Place', 'El Preferido');
    // A comma is the decimal separator here. Parsed naively this would drop
    // the price entirely and record nothing.
    await fillField(tester, 'Price', '12,50');
    await tapSave(tester);

    expect((await meals.list(const MealFilter())).single.price, 12.5);

    await unmount(tester);
  });

  testWidgets('records the dish, the company and the place', (tester) async {
    await pumpForm(tester);

    await fillField(tester, 'Place', 'Don Julio');
    await fillField(tester, 'Dish', 'Ojo de bife');
    await fillField(tester, 'With', 'Ana');
    await fillField(tester, 'Neighbourhood or city', 'Palermo');
    await tapSave(tester);

    final saved = (await meals.list(const MealFilter())).single;
    expect(saved.dish, 'Ojo de bife');
    expect(saved.company, 'Ana');
    expect(saved.location, 'Palermo');

    await unmount(tester);
  });

  testWidgets('leaves an unpriced meal without a price, not at zero', (
    tester,
  ) async {
    await pumpForm(tester);

    await fillField(tester, 'Place', 'El Preferido');
    await tapSave(tester);

    final saved = (await meals.list(const MealFilter())).single;
    expect(saved.price, isNull);
    expect(saved.dish, isNull);
    expect(saved.rating, isNull);

    await unmount(tester);
  });

  testWidgets('opens on the meal being edited and updates it in place', (
    tester,
  ) async {
    final original = await meals.create(
      MealDraft(
        title: 'Don Julio',
        happenedOn: DateTime(2026, 5, 2),
        dish: 'Ojo de bife',
      ),
    );

    await pumpForm(tester, meal: original);

    expect(find.text('Edit meal'), findsOneWidget);

    await fillField(tester, 'Dish', 'Entraña');
    await tapSave(tester);

    final all = await meals.list(const MealFilter());
    expect(all, hasLength(1), reason: 'editing must update, never insert');
    expect(all.single.id, original.id);
    expect(all.single.dish, 'Entraña');

    await unmount(tester);
  });
}
