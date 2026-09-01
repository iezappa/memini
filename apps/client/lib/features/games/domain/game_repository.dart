import '../../../core/tracking/domain/tracking_filter.dart';
import '../../../core/tracking/domain/tracking_repository.dart';
import 'game.dart';

/// Narrows a game list: the shared axes plus how it went and where it ran.
class GameFilter extends TrackingFilter {
  const GameFilter({
    super.query,
    super.minRating,
    super.sort,
    this.status,
    this.platform,
  });

  final GameStatus? status;
  final String? platform;

  @override
  bool get isEmpty => super.isEmpty && status == null && platform == null;

  @override
  GameFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    GameStatus? status,
    String? platform,
    bool clearQuery = false,
    bool clearMinRating = false,
    bool clearStatus = false,
    bool clearPlatform = false,
  }) {
    return GameFilter(
      query: clearQuery ? null : (query ?? this.query),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
      status: clearStatus ? null : (status ?? this.status),
      platform: clearPlatform ? null : (platform ?? this.platform),
    );
  }
}

abstract interface class GameRepository
    implements TrackingRepository<Game, GameDraft, GameFilter> {}
