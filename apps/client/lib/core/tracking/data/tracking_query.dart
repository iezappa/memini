import 'package:drift/drift.dart';

import '../domain/tracking_filter.dart';

/// The columns every tracked table exposes, handed to the shared query
/// helpers so five repositories do not each re-implement search and ordering.
///
/// Drift's generated columns carry their own value type, not their table, so
/// the helpers below compose against any table that can name these six.
class TrackingColumns {
  const TrackingColumns({
    required this.id,
    required this.title,
    required this.description,
    required this.review,
    required this.rating,
    required this.happenedOn,
  });

  final GeneratedColumn<int> id;
  final GeneratedColumn<String> title;
  final GeneratedColumn<String> description;
  final GeneratedColumn<String> review;
  final GeneratedColumn<double> rating;
  final GeneratedColumn<DateTime> happenedOn;
}

/// The shared part of a filter's WHERE clause, or null when nothing in it
/// narrows the query. Features AND their own predicates onto the result.
Expression<bool>? trackingPredicate(
  TrackingColumns columns,
  TrackingFilter filter,
) {
  final predicates = <Expression<bool>>[];

  final term = filter.searchTerm;
  if (term != null) {
    // LIKE is case-sensitive for non-ASCII in SQLite, so both sides are
    // lowered rather than trusting the collation.
    final pattern = '%${term.toLowerCase()}%';
    predicates.add(
      columns.title.lower().like(pattern) |
          columns.description.lower().like(pattern) |
          columns.review.lower().like(pattern),
    );
  }

  final minRating = filter.minRating;
  if (minRating != null) {
    predicates.add(columns.rating.isBiggerOrEqualValue(minRating));
  }

  if (predicates.isEmpty) return null;
  return predicates.reduce((a, b) => a & b);
}

/// The ordering terms for [sort].
///
/// Unrated entries sort last in both rating orders: a missing score is not a
/// zero, so it must never win the best or the worst slot.
List<OrderingTerm> trackingOrdering(
  TrackingColumns columns,
  TrackingSort sort,
) {
  return switch (sort) {
    TrackingSort.happenedOnDesc => [
      OrderingTerm(expression: columns.happenedOn, mode: OrderingMode.desc),
      OrderingTerm(expression: columns.id, mode: OrderingMode.desc),
    ],
    TrackingSort.happenedOnAsc => [
      OrderingTerm(expression: columns.happenedOn),
      OrderingTerm(expression: columns.id),
    ],
    TrackingSort.ratingDesc => [
      OrderingTerm(expression: columns.rating.isNull()),
      OrderingTerm(expression: columns.rating, mode: OrderingMode.desc),
      OrderingTerm(expression: columns.title.lower()),
    ],
    TrackingSort.ratingAsc => [
      OrderingTerm(expression: columns.rating.isNull()),
      OrderingTerm(expression: columns.rating),
      OrderingTerm(expression: columns.title.lower()),
    ],
    TrackingSort.titleAsc => [OrderingTerm(expression: columns.title.lower())],
  };
}
