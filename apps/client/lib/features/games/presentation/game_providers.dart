import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/clock.dart';
import '../../../core/enrichment/data/artwork_backfill.dart';
import '../../../core/enrichment/data/enrichment_providers.dart';
import '../../../core/tracking/presentation/tracking_filter_controller.dart';
import '../data/drift_game_repository.dart';
import '../domain/game.dart';
import '../domain/game_repository.dart';

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => DriftGameRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final gameFilterProvider = NotifierProvider<GameFilterController, GameFilter>(
  GameFilterController.new,
);

class GameFilterController extends TrackingFilterController<GameFilter> {
  @override
  GameFilter get pristine => const GameFilter();

  void setStatus(GameStatus? value) => state = value == null
      ? state.copyWith(clearStatus: true)
      : state.copyWith(status: value);

  void setPlatform(String? value) => state = value == null || value.isEmpty
      ? state.copyWith(clearPlatform: true)
      : state.copyWith(platform: value);
}

final gamesProvider = StreamProvider<List<Game>>((ref) {
  final filter = ref.watch(gameFilterProvider);
  return ref.watch(gameRepositoryProvider).watch(filter);
});

/// Every game, unfiltered — stats describe the whole record, not the view.
final allGamesProvider = StreamProvider<List<Game>>(
  (ref) => ref.watch(gameRepositoryProvider).watch(const GameFilter()),
);

final gameProvider = FutureProvider.family<Game?, String>((ref, id) {
  ref.watch(allGamesProvider);
  return ref.watch(gameRepositoryProvider).findById(id);
});

/// The distinct platforms already logged, for the platform filter.
final gamePlatformsProvider = Provider<List<String>>((ref) {
  final games = ref.watch(allGamesProvider).valueOrNull ?? const [];
  final seen = <String>{
    for (final game in games)
      if (game.platform != null && game.platform!.trim().isNotEmpty)
        game.platform!.trim(),
  };
  return seen.toList()..sort();
});

/// Fetches the cover for a game that was filled in from RAWG before the app
/// kept any, and writes it down once. See `viewingArtworkProvider`.
final gameArtworkProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final entry = await ref.watch(gameProvider(id).future);
  if (entry == null) return;
  if (entry.coverUrl != null || entry.externalId == null) return;

  final found = await findArtwork(
    source: ref.watch(rawgSourceProvider),
    title: entry.title,
    externalId: entry.externalId!,
  );
  if (found?.posterUrl == null) return;

  await ref
      .watch(gameRepositoryProvider)
      .update(entry.copyWith(coverUrl: found!.posterUrl));
  ref.invalidate(allGamesProvider);
});
