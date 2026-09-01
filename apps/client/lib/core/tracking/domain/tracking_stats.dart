import 'trackable.dart';

/// Aggregate figures that make sense for any tracked domain.
///
/// Domain-specific figures (escape rate, hours played, money spent) are
/// composed on top of this by each feature rather than added here.
class TrackingStats<T extends Trackable> {
  const TrackingStats({
    required this.total,
    required this.rated,
    required this.averageRating,
    required this.best,
    required this.perYear,
  });

  final int total;
  final int rated;

  /// Mean rating over rated entries only, or null when nothing is rated.
  final double? averageRating;

  /// Highest rated entry, or null when nothing is rated.
  final T? best;

  /// Number of entries per calendar year, newest year first.
  final Map<int, int> perYear;

  bool get isEmpty => total == 0;

  static TrackingStats<T> empty<T extends Trackable>() => TrackingStats<T>(
    total: 0,
    rated: 0,
    averageRating: null,
    best: null,
    perYear: const {},
  );

  /// Computes every figure in a single pass over [entries].
  factory TrackingStats.from(List<T> entries) {
    if (entries.isEmpty) return TrackingStats.empty<T>();

    var rated = 0;
    var ratingSum = 0.0;
    T? best;
    final perYear = <int, int>{};

    for (final entry in entries) {
      final rating = entry.rating;
      if (rating != null) {
        rated++;
        ratingSum += rating;
        // An unrated entry is not a zero, so it can never win the best slot.
        if (best == null || rating > best.rating!) best = entry;
      }

      perYear.update(
        entry.happenedOn.year,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final years = perYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return TrackingStats<T>(
      total: entries.length,
      rated: rated,
      averageRating: rated == 0 ? null : ratingSum / rated,
      best: best,
      perYear: {for (final year in years) year: perYear[year]!},
    );
  }
}
