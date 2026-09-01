import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/domain/tracking_filter.dart';
import 'package:memini/features/dining/data/drift_meal_repository.dart';
import 'package:memini/features/dining/domain/meal.dart';
import 'package:memini/features/dining/domain/meal_repository.dart';

void main() {
  late AppDatabase db;
  late DriftMealRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftMealRepository(db);
  });

  tearDown(() => db.close());

  Future<Meal> add({
    String title = 'Place',
    double? rating,
    DateTime? happenedOn,
    String? location,
    String? description,
    String? review,
  }) {
    return repository.create(
      MealDraft(
        title: title,
        happenedOn: happenedOn ?? DateTime(2026, 1, 1),
        rating: rating,
        location: location,
        description: description,
        review: review,
      ),
    );
  }

  Future<List<String>> titles(MealFilter filter) async =>
      (await repository.list(filter)).map((m) => m.title).toList();

  test('creates a meal and reads every field back', () async {
    final created = await repository.create(
      MealDraft(
        title: 'Don Julio',
        happenedOn: DateTime(2026, 3, 14, 21, 30),
        photoPath: '/p.jpg',
        description: 'Parrilla',
        rating: 9.5,
        review: 'The best bife I have had',
        dish: 'Bife de chorizo',
        price: 42000,
        company: 'Sofi',
        location: 'Palermo',
      ),
    );

    final reloaded = await repository.findById(created.id);

    expect(reloaded!.title, 'Don Julio');
    expect(reloaded.photoPath, '/p.jpg');
    expect(reloaded.description, 'Parrilla');
    expect(reloaded.rating, 9.5);
    expect(reloaded.review, 'The best bife I have had');
    expect(reloaded.dish, 'Bife de chorizo');
    expect(reloaded.price, 42000);
    expect(reloaded.company, 'Sofi');
    expect(reloaded.location, 'Palermo');
    expect(
      reloaded.happenedOn,
      DateTime(2026, 3, 14),
      reason: 'the time part is dropped like every other tracked domain',
    );
  });

  test(
    'inherits the shared search across title, description and review',
    () async {
      await add(title: 'Sushi Pop');
      await add(title: 'Cabin', description: 'Great sushi, oddly');
      await add(title: 'Prison', review: 'Felt like SUSHI');
      await add(title: 'Unrelated');

      final result = await titles(const MealFilter(query: 'sushi'));

      expect(result, hasLength(3));
      expect(result, isNot(contains('Unrelated')));
    },
  );

  test('inherits the shared ordering, unrated last on rating sorts', () async {
    await add(title: 'Unrated');
    await add(title: 'Great', rating: 9);
    await add(title: 'Poor', rating: 3);

    expect(await titles(const MealFilter(sort: TrackingSort.ratingDesc)), [
      'Great',
      'Poor',
      'Unrated',
    ]);
  });

  test('filters by location as a substring, ignoring case', () async {
    await add(title: 'Don Julio', location: 'Palermo Soho');
    await add(title: 'El Preferido', location: 'palermo');
    await add(title: 'Chuí', location: 'Villa Crespo');

    final result = await titles(const MealFilter(location: 'PALERMO'));

    expect(result, hasLength(2));
    expect(result, isNot(contains('Chuí')));
  });

  test('a meal with no location is not matched by a location filter', () async {
    await add(title: 'Nowhere');

    expect(await titles(const MealFilter(location: 'Palermo')), isEmpty);
  });

  test('updates a meal and can clear its price', () async {
    final created = await add(title: 'Old');
    await repository.update(
      created.copyWith(title: 'New', price: 100).copyWith(clearPrice: true),
    );

    final reloaded = await repository.findById(created.id);
    expect(reloaded!.title, 'New');
    expect(reloaded.price, isNull);
  });

  test('deletes a meal', () async {
    final created = await add();
    await repository.delete(created.id);
    expect(await repository.findById(created.id), isNull);
  });

  test('watch emits again when a meal is added', () async {
    final seen = <int>[];
    final subscription = repository
        .watch(const MealFilter())
        .listen((rows) => seen.add(rows.length));

    await pumpEventQueue();
    await add();
    await pumpEventQueue();

    expect(seen, [0, 1]);
    await subscription.cancel();
  });
}
