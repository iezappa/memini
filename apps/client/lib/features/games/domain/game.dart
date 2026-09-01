import '../../../core/tracking/domain/trackable.dart';

/// How far the owner got with a game.
///
/// [dropped] is deliberately a first-class outcome: abandoning a game is a
/// verdict, and a log that can only record finished games lies by omission.
enum GameStatus { playing, finished, hundredPercent, dropped }

/// A game the owner has played.
class Game implements Trackable {
  const Game({
    required this.id,
    required this.title,
    required this.happenedOn,
    required this.status,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    this.platform,
    this.hoursPlayed,
    this.releaseYear,
    this.externalId,
  });

  @override
  final int id;
  @override
  final String title;

  /// Cover art, either picked by the owner or cached from a lookup.
  @override
  final String? photoPath;
  @override
  final String? description;
  @override
  final double? rating;
  @override
  final String? review;

  /// Day the owner stopped playing — finished it, or put it down for good.
  @override
  final DateTime happenedOn;

  final GameStatus status;
  final String? platform;

  /// Hours on the clock. Fractional on purpose: "1.5" is a real answer.
  final double? hoursPlayed;
  final int? releaseYear;

  /// RAWG or IGDB id, cached when the owner enriched the entry.
  final String? externalId;

  @override
  bool get isRated => rating != null;

  bool get isFinished =>
      status == GameStatus.finished || status == GameStatus.hundredPercent;

  Game copyWith({
    String? title,
    String? photoPath,
    String? description,
    double? rating,
    String? review,
    DateTime? happenedOn,
    GameStatus? status,
    String? platform,
    double? hoursPlayed,
    int? releaseYear,
    String? externalId,
    bool clearPhoto = false,
    bool clearRating = false,
    bool clearHours = false,
    bool clearExternalId = false,
  }) {
    return Game(
      id: id,
      title: title ?? this.title,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      description: description ?? this.description,
      rating: clearRating ? null : (rating ?? this.rating),
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      hoursPlayed: clearHours ? null : (hoursPlayed ?? this.hoursPlayed),
      releaseYear: releaseYear ?? this.releaseYear,
      externalId: clearExternalId ? null : (externalId ?? this.externalId),
    );
  }
}

/// Input for creating a game, before the store assigns an id.
class GameDraft {
  const GameDraft({
    required this.title,
    required this.happenedOn,
    required this.status,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    this.platform,
    this.hoursPlayed,
    this.releaseYear,
    this.externalId,
  });

  final String title;
  final DateTime happenedOn;
  final GameStatus status;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final String? platform;
  final double? hoursPlayed;
  final int? releaseYear;
  final String? externalId;
}
