import '../../../core/tracking/domain/tracking_filter.dart';
import '../../../core/tracking/domain/tracking_repository.dart';
import 'meal.dart';

/// Narrows a meal list.
///
/// Only the shared axes. There used to be one of its own — the
/// neighbourhood — and it went when the neighbourhood became a map link in
/// schema v9: a list of links is not something anybody filters by.
class MealFilter extends TrackingFilter {
  const MealFilter({super.query, super.minRating, super.sort});

  @override
  MealFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    bool clearQuery = false,
    bool clearMinRating = false,
  }) {
    return MealFilter(
      query: clearQuery ? null : (query ?? this.query),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
    );
  }
}

abstract interface class MealRepository
    implements TrackingRepository<Meal, MealDraft, MealFilter> {}
