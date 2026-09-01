import '../../../core/tracking/domain/trackable.dart';
import '../../../core/tracking/domain/tracked_domain.dart';
import '../../../core/tracking/domain/tracking_stats.dart';

/// Everything logged, across every domain.
///
/// Kept separate from the per-domain [TrackingStats] because the questions
/// differ: a domain asks "how good were my meals", the whole log asks "what
/// did I actually do this year".
class MeminiStats {
  const MeminiStats({
    required this.perDomain,
    required this.total,
    required this.rated,
    required this.averageRating,
    required this.best,
    required this.perYear,
  });

  /// How many entries each domain holds. Every domain is present, including
  /// the ones at zero — a missing key would read as "unknown", not "none".
  final Map<TrackedDomain, int> perDomain;

  final int total;
  final int rated;

  /// Mean rating over every rated entry, whatever the domain.
  final double? averageRating;

  /// The single highest rated thing in the whole log.
  final ({TrackedDomain domain, Trackable entry})? best;

  /// Entries per calendar year across every domain, newest year first.
  final Map<int, int> perYear;

  bool get isEmpty => total == 0;

  /// Folds one entry list per domain into a single picture.
  factory MeminiStats.from(Map<TrackedDomain, List<Trackable>> entries) {
    final perDomain = <TrackedDomain, int>{
      for (final domain in TrackedDomain.values)
        domain: entries[domain]?.length ?? 0,
    };

    var total = 0;
    var rated = 0;
    var ratingSum = 0.0;
    ({TrackedDomain domain, Trackable entry})? best;
    final perYear = <int, int>{};

    for (final domain in TrackedDomain.values) {
      for (final entry in entries[domain] ?? const <Trackable>[]) {
        total++;

        final rating = entry.rating;
        if (rating != null) {
          rated++;
          ratingSum += rating;
          // An unrated entry is not a zero, so it can never take the top slot.
          if (best == null || rating > best.entry.rating!) {
            best = (domain: domain, entry: entry);
          }
        }

        perYear.update(
          entry.happenedOn.year,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final years = perYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return MeminiStats(
      perDomain: perDomain,
      total: total,
      rated: rated,
      averageRating: rated == 0 ? null : ratingSum / rated,
      best: best,
      perYear: {for (final year in years) year: perYear[year]!},
    );
  }
}
