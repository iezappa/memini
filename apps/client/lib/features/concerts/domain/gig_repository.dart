import '../../../core/tracking/domain/tracking_filter.dart';
import '../../../core/tracking/domain/tracking_repository.dart';
import 'gig.dart';

/// Narrows a gig list: the shared axes plus where it happened.
class GigFilter extends TrackingFilter {
  const GigFilter({super.query, super.minRating, super.sort, this.city});

  final String? city;

  @override
  bool get isEmpty => super.isEmpty && city == null;

  @override
  GigFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    String? city,
    bool clearQuery = false,
    bool clearMinRating = false,
    bool clearCity = false,
  }) {
    return GigFilter(
      query: clearQuery ? null : (query ?? this.query),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
      city: clearCity ? null : (city ?? this.city),
    );
  }
}

abstract interface class GigRepository
    implements TrackingRepository<Gig, GigDraft, GigFilter> {}
