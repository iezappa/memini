/// How a tracked list is ordered. Every domain offers the same four axes;
/// anything domain-specific is a filter, not a sort.
enum TrackingSort {
  happenedOnDesc,
  happenedOnAsc,
  ratingDesc,
  ratingAsc,
  titleAsc,
}

/// Narrows a tracked list on the axes every domain shares.
///
/// Each feature extends this with its own fields — a room filters by
/// franchise, a game by platform — so the shared query builder can handle
/// search, rating and ordering once for all five.
class TrackingFilter {
  const TrackingFilter({
    this.query,
    this.minRating,
    this.sort = TrackingSort.happenedOnDesc,
  });

  /// Free text matched against title, description and review.
  final String? query;
  final double? minRating;
  final TrackingSort sort;

  /// The query with surrounding space removed, or null when it would match
  /// everything anyway. Callers should never read [query] directly.
  String? get searchTerm {
    final trimmed = query?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// Whether the filter narrows the list at all. Ordering is deliberately not
  /// part of this: a sort changes the view, it does not hide anything.
  bool get isEmpty => searchTerm == null && minRating == null;

  TrackingFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    bool clearQuery = false,
    bool clearMinRating = false,
  }) {
    return TrackingFilter(
      query: clearQuery ? null : (query ?? this.query),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
    );
  }
}

/// Normalises a timestamp to its calendar day.
///
/// Entries are tracked by day; keeping the time part would only make two
/// entries recorded on the same day sort against each other by chance.
DateTime dayOf(DateTime value) => DateTime(value.year, value.month, value.day);
