import '../../../core/tracking/domain/tracking_filter.dart';
import '../../../core/tracking/domain/tracking_repository.dart';
import 'meal.dart';

/// Narrows a meal list: the shared axes plus where it was.
class MealFilter extends TrackingFilter {
  const MealFilter({super.query, super.minRating, super.sort, this.location});

  /// Matched as a substring, so "Palermo" finds every place in the area.
  final String? location;

  @override
  bool get isEmpty => super.isEmpty && location == null;

  @override
  MealFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    String? location,
    bool clearQuery = false,
    bool clearMinRating = false,
    bool clearLocation = false,
  }) {
    return MealFilter(
      query: clearQuery ? null : (query ?? this.query),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
      location: clearLocation ? null : (location ?? this.location),
    );
  }
}

abstract interface class MealRepository
    implements TrackingRepository<Meal, MealDraft, MealFilter> {}
