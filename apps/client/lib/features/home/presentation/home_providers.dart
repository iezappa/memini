import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../core/tracking/domain/trackable.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../concerts/presentation/gig_providers.dart';
import '../../dining/presentation/meal_providers.dart';
import '../../games/presentation/game_providers.dart';
import '../../../app/providers.dart';
import '../../screen/presentation/viewing_providers.dart';
import '../domain/activity_grid.dart';

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
