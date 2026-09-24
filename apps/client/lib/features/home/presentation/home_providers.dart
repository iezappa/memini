import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../core/tracking/domain/trackable.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../concerts/presentation/gig_providers.dart';
import '../../dining/presentation/meal_providers.dart';
import '../../games/presentation/game_providers.dart';
import '../../../app/providers.dart';
import '../../screen/presentation/viewing_providers.dart';
import '../data/rawg_recommendations.dart';
import '../data/tmdb_recommendations.dart';
import '../domain/activity_grid.dart';
import '../domain/recommendation.dart';

/// One entry from any domain, tagged with where it came from.
///
/// The hub is the only place the five domains are ever mixed, so this pairing
/// lives here rather than polluting the shared Trackable contract.
class DomainEntry {
  const DomainEntry({required this.domain, required this.entry});

  final TrackedDomain domain;
  final Trackable entry;
}

/// How many entries each domain holds, for the hub's tiles.
final domainCountsProvider = Provider<Map<TrackedDomain, int>>((ref) {
  return {
    TrackedDomain.rooms: ref.watch(allRoomsProvider).valueOrNull?.length ?? 0,
    TrackedDomain.dining: ref.watch(allMealsProvider).valueOrNull?.length ?? 0,
    TrackedDomain.concerts: ref.watch(allGigsProvider).valueOrNull?.length ?? 0,
    TrackedDomain.screen:
        ref.watch(allViewingsProvider).valueOrNull?.length ?? 0,
    TrackedDomain.games: ref.watch(allGamesProvider).valueOrNull?.length ?? 0,
  };
});

/// The most recent entries across every domain, newest first.
///
/// Sorted in memory on purpose: five small lists beat a UNION query that
/// would have to flatten five different shapes into one row type.
final recentEntriesProvider = Provider<List<DomainEntry>>((ref) {
  final all = <DomainEntry>[
    for (final room in ref.watch(allRoomsProvider).valueOrNull ?? const [])
      DomainEntry(domain: TrackedDomain.rooms, entry: room),
    for (final meal in ref.watch(allMealsProvider).valueOrNull ?? const [])
      DomainEntry(domain: TrackedDomain.dining, entry: meal),
    for (final gig in ref.watch(allGigsProvider).valueOrNull ?? const [])
      DomainEntry(domain: TrackedDomain.concerts, entry: gig),
    for (final viewing
        in ref.watch(allViewingsProvider).valueOrNull ?? const [])
      DomainEntry(domain: TrackedDomain.screen, entry: viewing),
    for (final game in ref.watch(allGamesProvider).valueOrNull ?? const [])
      DomainEntry(domain: TrackedDomain.games, entry: game),
  ];

  all.sort((a, b) => b.entry.happenedOn.compareTo(a.entry.happenedOn));
  return all.take(8).toList();
});

/// How many weeks of squares the grid shows.
///
/// Half a year. Fifty-two would be the familiar shape but it cannot be read
/// on a phone without scrolling past most of it, and this grid answers "have
/// I been out lately" rather than "what did I do last spring".
const activityWeeks = 26;

/// Every entry of every domain, counted by the day it happened on.
///
/// Built from the same five lists the rest of the hub reads rather than from
/// a query of its own: they are already in memory, and a UNION over five
/// tables would have to flatten five different shapes into one row type for
/// an answer that is one integer per day.
final activityGridProvider = Provider<ActivityGrid>((ref) {
  final counts = <DateTime, int>{};
  for (final entry in _everything(ref)) {
    final day = dateOnly(entry.happenedOn);
    counts[day] = (counts[day] ?? 0) + 1;
  }

  final today = ref.watch(clockProvider)();
  // Counted back in whole weeks rather than in days, so the grid is exactly
  // [activityWeeks] columns wide however far into the week today is.
  final window = ActivityWindow(
    from: DateTime(
      today.year,
      today.month,
      today.day - (activityWeeks - 1) * 7,
    ),
    to: today,
  );

  return ActivityGrid.from(
    window,
    counts,
    // Weeks start on Monday, as they do everywhere else in the app.
    firstWeekday: DateTime.monday,
  );
});

Iterable<Trackable> _everything(Ref ref) => [
  ...?ref.watch(allRoomsProvider).valueOrNull,
  ...?ref.watch(allMealsProvider).valueOrNull,
  ...?ref.watch(allGigsProvider).valueOrNull,
  ...?ref.watch(allViewingsProvider).valueOrNull,
  ...?ref.watch(allGamesProvider).valueOrNull,
];

/// The three figures the hub prints instead of a count per domain.
///
/// The counts per domain moved out: with a tab per section, five tiles that
/// each said a number and the name of the tab under it were a second copy of
/// the navigation. These are things the navigation cannot tell you.
typedef HomeNumbers = ({int entries, double? rating, int thisMonth});

final homeNumbersProvider = Provider<HomeNumbers>((ref) {
  final all = _everything(ref).toList();
  final today = ref.watch(clockProvider)();

  final rated = [for (final entry in all) ?entry.rating];

  return (
    entries: all.length,
    // Null rather than zero when nothing is rated: an average of no scores
    // is not a score of zero.
    rating: rated.isEmpty ? null : rated.reduce((a, b) => a + b) / rated.length,
    thisMonth: all
        .where(
          (entry) =>
              entry.happenedOn.year == today.year &&
              entry.happenedOn.month == today.month,
        )
        .length,
  );
});

/// The two shelves the hub can offer, films first.
final recommendationSourcesProvider = Provider<List<RecommendationSource>>((
  ref,
) {
  return [
    TmdbRecommendations(apiKey: ref.watch(tmdbApiKeyProvider)),
    RawgRecommendations(apiKey: ref.watch(rawgApiKeyProvider)),
  ];
});

/// Bumped by "another", so the hub asks for a fresh pick.
final suggestionRollProvider = StateProvider<int>((ref) => 0);

/// One thing to watch and one to play, drawn at random.
///
/// Fetched once per roll rather than per rebuild, and nothing is written
/// down: this is a nudge, not a record. A source with no key is left out
/// silently — the shelf says what to do about it once, for all of them.
///
/// The whole thing fails soft. A shelf that could not load is a shelf that
/// is not there; it must never be the reason the hub does not open.
final suggestionsProvider = FutureProvider<List<Recommendation>>((ref) async {
  ref.watch(suggestionRollProvider);

  final sources = ref
      .watch(recommendationSourcesProvider)
      .where((source) => source.isConfigured);
  if (sources.isEmpty) {
    throw const RecommendationException(RecommendationFailure.missingKey);
  }

  // Seeded from the roll, so "another" gives a different pick and a rebuild
  // does not: a shelf that reshuffles whenever the page repaints is a shelf
  // nobody can read.
  final picker = Random(ref.watch(suggestionRollProvider));

  final picks = <Recommendation>[];
  for (final source in sources) {
    try {
      final page = await source.popular();
      if (page.isEmpty) continue;
      picks.add(page[picker.nextInt(page.length)]);
    } on RecommendationException {
      // One source being down is not the other one's problem.
      continue;
    }
  }

  if (picks.isEmpty) {
    throw const RecommendationException(RecommendationFailure.unavailable);
  }

  return picks;
});
