import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/tracking/presentation/tracking_filter_controller.dart';
import '../data/drift_meal_repository.dart';
import '../domain/meal.dart';
import '../domain/meal_repository.dart';

final mealRepositoryProvider = Provider<MealRepository>(
  (ref) => DriftMealRepository(ref.watch(databaseProvider)),
);

final mealFilterProvider = NotifierProvider<MealFilterController, MealFilter>(
  MealFilterController.new,
);

class MealFilterController extends TrackingFilterController<MealFilter> {
  @override
  MealFilter get pristine => const MealFilter();

  void setLocation(String? value) => state = value == null || value.isEmpty
      ? state.copyWith(clearLocation: true)
      : state.copyWith(location: value);
}

final mealsProvider = StreamProvider<List<Meal>>((ref) {
  final filter = ref.watch(mealFilterProvider);
  return ref.watch(mealRepositoryProvider).watch(filter);
});

/// Every meal, unfiltered — stats describe the whole record, not the view.
final allMealsProvider = StreamProvider<List<Meal>>(
  (ref) => ref.watch(mealRepositoryProvider).watch(const MealFilter()),
);

final mealProvider = FutureProvider.family<Meal?, int>((ref, id) {
  // Re-resolves whenever the collection changes so an edit is reflected
  // without the detail screen having to invalidate itself.
  ref.watch(allMealsProvider);
  return ref.watch(mealRepositoryProvider).findById(id);
});

/// The distinct places already logged, for the location filter.
final mealLocationsProvider = Provider<List<String>>((ref) {
  final meals = ref.watch(allMealsProvider).valueOrNull ?? const [];
  final seen = <String>{
    for (final meal in meals)
      if (meal.location != null && meal.location!.trim().isNotEmpty)
        meal.location!.trim(),
  };
  return seen.toList()..sort();
});
