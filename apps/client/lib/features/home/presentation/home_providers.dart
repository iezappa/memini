import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tracking/domain/trackable.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../concerts/presentation/gig_providers.dart';
import '../../dining/presentation/meal_providers.dart';
import '../../games/presentation/game_providers.dart';
import '../../../app/providers.dart';
import '../../screen/presentation/viewing_providers.dart';

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
