import '../../../core/tracking/domain/trackable.dart';

/// What kind of thing was watched.
///
/// Kept coarse on purpose: the difference that matters to the owner is
/// "one sitting" versus "many", not the exact industry category.
enum ViewingKind { film, series, miniseries, documentary }

/// A film or series the owner has watched.
class Viewing implements Trackable {
  const Viewing({
    required this.id,
    required this.title,
    required this.happenedOn,
    required this.kind,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    this.releaseYear,
    this.director,
    this.cast,
    this.season,
    this.externalId,
  });

  @override
  final int id;
  @override
  final String title;

  /// Poster, either picked by the owner or cached from a lookup.
  @override
  final String? photoPath;

  /// Synopsis — filled by the owner, or by an enrichment lookup.
  @override
  final String? description;
  @override
  final double? rating;
  @override
  final String? review;

  /// Day it was watched — or the day the season was finished.
  @override
  final DateTime happenedOn;

  final ViewingKind kind;
  final int? releaseYear;
  final String? director;

  /// Principal cast, comma separated.
  final String? cast;

  /// Which season this entry covers. Null for anything watched in one go.
  final int? season;

  /// TMDB id, cached when the owner enriched the entry.
  final String? externalId;

  @override
  bool get isRated => rating != null;

  Viewing copyWith({
    String? title,
    String? photoPath,
    String? description,
    double? rating,
    String? review,
    DateTime? happenedOn,
    ViewingKind? kind,
    int? releaseYear,
    String? director,
    String? cast,
    int? season,
    String? externalId,
    bool clearPhoto = false,
    bool clearRating = false,
    bool clearSeason = false,
    bool clearExternalId = false,
  }) {
    return Viewing(
      id: id,
      title: title ?? this.title,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      description: description ?? this.description,
      rating: clearRating ? null : (rating ?? this.rating),
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      kind: kind ?? this.kind,
      releaseYear: releaseYear ?? this.releaseYear,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      season: clearSeason ? null : (season ?? this.season),
      externalId: clearExternalId ? null : (externalId ?? this.externalId),
    );
  }
}

/// Input for creating a viewing, before the store assigns an id.
class ViewingDraft {
  const ViewingDraft({
    required this.title,
    required this.happenedOn,
    required this.kind,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    this.releaseYear,
    this.director,
    this.cast,
    this.season,
    this.externalId,
  });

  final String title;
  final DateTime happenedOn;
  final ViewingKind kind;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final int? releaseYear;
  final String? director;
  final String? cast;
  final int? season;
  final String? externalId;
}
