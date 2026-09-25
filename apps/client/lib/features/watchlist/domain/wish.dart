import '../../../core/tracking/domain/tracking_filter.dart';

/// What a wish is for.
///
/// Three kinds rather than five: a meal and an escape room are places you go
/// when you feel like it, and nobody keeps a list of them. What people keep
/// a list of is the film everyone is talking about, the game waiting for a
/// sale, and the band whose tour has not been announced yet.
enum WishKind { screen, game, music }

/// Something the owner means to watch, play or see.
///
/// Deliberately not a [Trackable]: a wish has not happened, has no score and
/// no review, and the day that matters is the day it was added rather than
/// the day it took place. Making it one would have given every wish a date
/// it did not have and a rating nobody could fill in.
class Wish {
  const Wish({
    required this.id,
    required this.kind,
    required this.title,
    required this.addedOn,
    this.updatedAt,
    this.note,
    this.description,
    this.releaseYear,
    this.externalId,
    this.posterUrl,
  });

  final String id;
  final WishKind kind;
  final String title;

  /// The day it was put on the list, which is the only date a wish has.
  final DateTime addedOn;
  final DateTime? updatedAt;

  /// Why it is on the list: who recommended it, where it is streaming, that
  /// it is waiting for a sale. The owner's own words, never a lookup's.
  final String? note;

  /// The synopsis a lookup found, kept so the list says what the thing is
  /// without opening anything.
  final String? description;
  final int? releaseYear;

  /// TMDB, RAWG or MusicBrainz id, cached when the wish was looked up — the
  /// entry made from it inherits it, so its artwork is already known.
  final String? externalId;
  final String? posterUrl;

  Wish copyWith({
    WishKind? kind,
    String? title,
    String? note,
    String? description,
    int? releaseYear,
    String? externalId,
    String? posterUrl,
    bool clearNote = false,
    bool clearExternalId = false,
  }) {
    return Wish(
      id: id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      addedOn: addedOn,
      updatedAt: updatedAt,
      note: clearNote ? null : (note ?? this.note),
      description: description ?? this.description,
      releaseYear: releaseYear ?? this.releaseYear,
      externalId: clearExternalId ? null : (externalId ?? this.externalId),
      // Cleared with the id it came from, like everywhere else: artwork
      // that outlives the title it belongs to is a wrong picture.
      posterUrl: clearExternalId ? null : (posterUrl ?? this.posterUrl),
    );
  }
}

/// A wish before the store gives it an id.
class WishDraft {
  const WishDraft({
    required this.kind,
    required this.title,
    required this.addedOn,
    this.note,
    this.description,
    this.releaseYear,
    this.externalId,
    this.posterUrl,
  });

  final WishKind kind;
  final String title;
  final DateTime addedOn;
  final String? note;
  final String? description;
  final int? releaseYear;
  final String? externalId;
  final String? posterUrl;
}

/// Narrows the watchlist: the shared search and ordering, plus the one axis
/// a wish has of its own.
class WishFilter extends TrackingFilter {
  const WishFilter({super.query, super.sort, this.kind});

  final WishKind? kind;

  @override
  bool get isEmpty => super.isEmpty && kind == null;

  @override
  WishFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    WishKind? kind,
    bool clearQuery = false,
    bool clearMinRating = false,
    bool clearKind = false,
  }) {
    return WishFilter(
      query: clearQuery ? null : (query ?? this.query),
      sort: sort ?? this.sort,
      kind: clearKind ? null : (kind ?? this.kind),
    );
  }
}

/// Where the watchlist is kept.
abstract interface class WishRepository {
  Future<List<Wish>> list(WishFilter filter);

  Future<Wish?> findById(String id);

  Future<Wish> create(WishDraft draft);

  Future<void> update(Wish wish);

  Future<void> delete(String id);

  Stream<List<Wish>> watch(WishFilter filter);
}
