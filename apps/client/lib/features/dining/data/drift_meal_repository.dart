import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tracking/data/tracking_query.dart';
import '../../../core/tracking/domain/tracking_filter.dart';
import '../domain/meal.dart';
import '../domain/meal_repository.dart';

class DriftMealRepository implements MealRepository {
  DriftMealRepository(this._db);

  final AppDatabase _db;

  TrackingColumns get _columns {
    final meals = _db.meals;
    return TrackingColumns(
      id: meals.id,
      title: meals.title,
      description: meals.description,
      review: meals.review,
      rating: meals.rating,
      happenedOn: meals.happenedOn,
    );
  }

  Meal _toDomain(MealRow row) => Meal(
    id: row.id,
    title: row.title,
    photoPath: row.photoPath,
    description: row.description,
    rating: row.rating,
    review: row.review,
    happenedOn: row.happenedOn,
    dish: row.dish,
    price: row.price,
    company: row.company,
    location: row.location,
  );

  SimpleSelectStatement<$MealsTable, MealRow> _query(MealFilter filter) {
    final query = _db.select(_db.meals);

    final shared = trackingPredicate(_columns, filter);
    if (shared != null) query.where((_) => shared);

    final location = filter.location?.trim();
    if (location != null && location.isNotEmpty) {
      final pattern = '%${location.toLowerCase()}%';
      query.where((m) => m.location.lower().like(pattern));
    }

    final ordering = trackingOrdering(_columns, filter.sort);
    query.orderBy([for (final term in ordering) (_) => term]);

    return query;
  }

  @override
  Future<List<Meal>> list(MealFilter filter) async =>
      (await _query(filter).get()).map(_toDomain).toList();

  @override
  Stream<List<Meal>> watch(MealFilter filter) =>
      _query(filter).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Meal?> findById(int id) async {
    final row = await (_db.select(
      _db.meals,
    )..where((m) => m.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Meal> create(MealDraft draft) async {
    final row = await _db
        .into(_db.meals)
        .insertReturning(
          MealsCompanion.insert(
            title: draft.title.trim(),
            happenedOn: dayOf(draft.happenedOn),
            photoPath: Value(draft.photoPath),
            description: Value(draft.description),
            rating: Value(draft.rating),
            review: Value(draft.review),
            dish: Value(draft.dish),
            price: Value(draft.price),
            company: Value(draft.company),
            location: Value(draft.location),
          ),
        );
    return _toDomain(row);
  }

  @override
  Future<void> update(Meal entry) async {
    await (_db.update(_db.meals)..where((m) => m.id.equals(entry.id))).write(
      MealsCompanion(
        title: Value(entry.title.trim()),
        photoPath: Value(entry.photoPath),
        description: Value(entry.description),
        rating: Value(entry.rating),
        review: Value(entry.review),
        happenedOn: Value(dayOf(entry.happenedOn)),
        dish: Value(entry.dish),
        price: Value(entry.price),
        company: Value(entry.company),
        location: Value(entry.location),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.meals)..where((m) => m.id.equals(id))).go();
  }
}
