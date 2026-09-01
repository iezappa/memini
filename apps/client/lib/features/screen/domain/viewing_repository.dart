import '../../../core/tracking/domain/tracking_filter.dart';
import '../../../core/tracking/domain/tracking_repository.dart';
import 'viewing.dart';

/// Narrows a viewing list: the shared axes plus what kind of thing it was.
class ViewingFilter extends TrackingFilter {
  const ViewingFilter({super.query, super.minRating, super.sort, this.kind});

  final ViewingKind? kind;

  @override
  bool get isEmpty => super.isEmpty && kind == null;

  @override
  ViewingFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    ViewingKind? kind,
    bool clearQuery = false,
    bool clearMinRating = false,
    bool clearKind = false,
  }) {
    return ViewingFilter(
      query: clearQuery ? null : (query ?? this.query),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
      kind: clearKind ? null : (kind ?? this.kind),
    );
  }
}

abstract interface class ViewingRepository
    implements TrackingRepository<Viewing, ViewingDraft, ViewingFilter> {}
