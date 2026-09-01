import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/tracking/presentation/tracking_filter_controller.dart';
import '../data/drift_game_repository.dart';
import '../domain/game.dart';
import '../domain/game_repository.dart';

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => DriftGameRepository(ref.watch(databaseProvider)),
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

final gameProvider = FutureProvider.family<Game?, int>((ref, id) {
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
