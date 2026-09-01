import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/tracking/domain/trackable.dart';
import '../../../core/tracking/domain/tracked_domain.dart';
import '../../concerts/presentation/gig_providers.dart';
import '../../dining/presentation/meal_providers.dart';
import '../../games/presentation/game_providers.dart';
import '../../screen/presentation/viewing_providers.dart';
import '../domain/memini_stats.dart';

/// Every entry in the log, grouped by domain.
final entriesByDomainProvider = Provider<Map<TrackedDomain, List<Trackable>>>((
  ref,
) {
  return {
    TrackedDomain.rooms: ref.watch(allRoomsProvider).valueOrNull ?? const [],
    TrackedDomain.dining: ref.watch(allMealsProvider).valueOrNull ?? const [],
    TrackedDomain.concerts: ref.watch(allGigsProvider).valueOrNull ?? const [],
    TrackedDomain.screen:
        ref.watch(allViewingsProvider).valueOrNull ?? const [],
    TrackedDomain.games: ref.watch(allGamesProvider).valueOrNull ?? const [],
  };
});

final meminiStatsProvider = Provider<MeminiStats>(
  (ref) => MeminiStats.from(ref.watch(entriesByDomainProvider)),
);

/// Total hours across every logged game, or null when none are recorded.
final hoursPlayedProvider = Provider<double?>((ref) {
  final games = ref.watch(allGamesProvider).valueOrNull ?? const [];
  final withHours = games.where((game) => game.hoursPlayed != null);
  if (withHours.isEmpty) return null;
  return withHours.fold<double>(0.0, (sum, game) => sum + game.hoursPlayed!);
});

/// Total spent across every meal with a price, or null when none have one.
final moneySpentProvider = Provider<double?>((ref) {
  final meals = ref.watch(allMealsProvider).valueOrNull ?? const [];
  final priced = meals.where((meal) => meal.price != null);
  if (priced.isEmpty) return null;
  return priced.fold<double>(0.0, (sum, meal) => sum + meal.price!);
});
