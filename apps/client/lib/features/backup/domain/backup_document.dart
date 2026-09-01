library;

import '../../../core/tracking/domain/trackable.dart';
import '../../concerts/domain/gig.dart';
import '../../dining/domain/meal.dart';
import '../../franchises/domain/franchise.dart';
import '../../games/domain/game.dart';
import '../../rooms/domain/room.dart';
import '../../screen/domain/viewing.dart';

/// Raised when an imported file is not a Memini backup this build understands.
class BackupFormatException implements Exception {
  const BackupFormatException(this.reason);

  final String reason;

  @override
  String toString() => 'BackupFormatException: $reason';
}

/// The whole database as one portable, versioned document.
///
/// Framework-free on purpose: no Flutter and no Drift imports, so the format
/// can be tested and evolved without touching persistence.
class BackupDocument {
  const BackupDocument({
    required this.version,
    required this.exportedAt,
    required this.franchises,
    required this.rooms,
    required this.meals,
    required this.gigs,
    required this.viewings,
    required this.games,
  });

  /// Bumped whenever the shape changes in a way older builds cannot read.
  ///
  /// v2 added the four domains beyond escape rooms. A v1 file still restores
  /// cleanly: its missing lists simply read as empty.
  static const currentVersion = 2;

  final int version;
  final DateTime exportedAt;
  final List<Franchise> franchises;
  final List<Room> rooms;
  final List<Meal> meals;
  final List<Gig> gigs;
  final List<Viewing> viewings;
  final List<Game> games;

  factory BackupDocument.of({
    required List<Franchise> franchises,
    required List<Room> rooms,
    List<Meal> meals = const [],
    List<Gig> gigs = const [],
    List<Viewing> viewings = const [],
    List<Game> games = const [],
    DateTime? exportedAt,
  }) {
    return BackupDocument(
      version: currentVersion,
      exportedAt: exportedAt ?? DateTime.now(),
      franchises: franchises,
      rooms: rooms,
      meals: meals,
      gigs: gigs,
      viewings: viewings,
      games: games,
    );
  }

  /// Every tracked entry the document holds, whatever the domain. Useful for
  /// a caller that just wants to know whether a restore would lose anything.
  int get entryCount =>
      rooms.length +
      meals.length +
      gigs.length +
      viewings.length +
      games.length;

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportedAt': exportedAt.toIso8601String(),
    'franchises': [
      for (final f in franchises)
        {'id': f.id, 'name': f.name, 'logoPath': f.logoPath},
    ],
    'rooms': [
      for (final r in rooms)
        {
          ..._commonJson(r),
          'franchiseId': r.franchiseId,
          'escaped': r.escaped,
          'timeLeftMinutes': r.timeLeftMinutes,
        },
    ],
    'meals': [
      for (final m in meals)
        {
          ..._commonJson(m),
          'dish': m.dish,
          'price': m.price,
          'company': m.company,
          'location': m.location,
        },
    ],
    'gigs': [
      for (final g in gigs)
        {
          ..._commonJson(g),
          'venue': g.venue,
          'city': g.city,
          'supportActs': g.supportActs,
          'setlist': g.setlist,
          'company': g.company,
          'externalId': g.externalId,
        },
    ],
    'viewings': [
      for (final v in viewings)
        {
          ..._commonJson(v),
          // Enums travel by name, not index: a reordered enum would silently
          // turn every film into a series if the index were the contract.
          'kind': v.kind.name,
          'releaseYear': v.releaseYear,
          'director': v.director,
          'cast': v.cast,
          'season': v.season,
          'externalId': v.externalId,
        },
    ],
    'games': [
      for (final g in games)
        {
          ..._commonJson(g),
          'status': g.status.name,
          'platform': g.platform,
          'hoursPlayed': g.hoursPlayed,
          'releaseYear': g.releaseYear,
          'externalId': g.externalId,
        },
    ],
  };

  static Map<String, dynamic> _commonJson(Trackable entry) => {
    'id': entry.id,
    'title': entry.title,
    'photoPath': entry.photoPath,
    'description': entry.description,
    'rating': entry.rating,
    'review': entry.review,
    'happenedOn': _dateOnly(entry.happenedOn),
  };

  /// Validates the whole document before returning it, so a malformed file
  /// can never be half-applied to the database.
  factory BackupDocument.fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      throw const BackupFormatException('not-an-object');
    }

    final version = raw['version'];
    if (version is! int) throw const BackupFormatException('missing-version');
    if (version > currentVersion) {
      throw const BackupFormatException('version-too-new');
    }

    final exportedAt = DateTime.tryParse(raw['exportedAt'] as String? ?? '');
    if (exportedAt == null) {
      throw const BackupFormatException('missing-exported-at');
    }

    final franchises = _listOf(raw['franchises']).map(_franchise).toList();
    final knownIds = {for (final f in franchises) f.id};
    final rooms = _listOf(raw['rooms']).map(_room).toList();

    for (final room in rooms) {
      if (room.franchiseId != null && !knownIds.contains(room.franchiseId)) {
        throw const BackupFormatException('dangling-franchise-reference');
      }
    }

    return BackupDocument(
      version: version,
      exportedAt: exportedAt,
      franchises: franchises,
      rooms: rooms,
      meals: _listOf(raw['meals']).map(_meal).toList(),
      gigs: _listOf(raw['gigs']).map(_gig).toList(),
      viewings: _listOf(raw['viewings']).map(_viewing).toList(),
      games: _listOf(raw['games']).map(_game).toList(),
    );
  }

  static List<Map<String, dynamic>> _listOf(Object? value) {
    if (value == null) return const [];
    if (value is! List) throw const BackupFormatException('expected-list');
    return value.map((e) {
      if (e is! Map<String, dynamic>) {
        throw const BackupFormatException('expected-object');
      }
      return e;
    }).toList();
  }

  static Franchise _franchise(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! int || name is! String || name.trim().isEmpty) {
      throw const BackupFormatException('invalid-franchise');
    }
    return Franchise(id: id, name: name, logoPath: json['logoPath'] as String?);
  }

  /// The fields every entry shares, validated once instead of five times.
  static _Common _common(Map<String, dynamic> json, String reason) {
    final id = json['id'];
    final title = json['title'];
    final happenedOn = DateTime.tryParse(json['happenedOn'] as String? ?? '');

    if (id is! int ||
        title is! String ||
        title.trim().isEmpty ||
        happenedOn == null) {
      throw BackupFormatException(reason);
    }

    final rating = (json['rating'] as num?)?.toDouble();
    if (rating != null && (rating < kMinRating || rating > kMaxRating)) {
      throw const BackupFormatException('rating-out-of-range');
    }

    return _Common(
      id: id,
      title: title,
      photoPath: json['photoPath'] as String?,
      description: json['description'] as String?,
      rating: rating,
      review: json['review'] as String?,
      happenedOn: DateTime(happenedOn.year, happenedOn.month, happenedOn.day),
    );
  }

  /// Resolves an enum by name, refusing anything this build does not know
  /// rather than guessing and silently mislabelling the entry.
  static T _enumByName<T extends Enum>(
    Object? value,
    List<T> values,
    String reason,
  ) {
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    throw BackupFormatException(reason);
  }

  static Room _room(Map<String, dynamic> json) {
    final common = _common(json, 'invalid-room');
    final escaped = json['escaped'];
    if (escaped is! bool) throw const BackupFormatException('invalid-room');

    return Room(
      id: common.id,
      title: common.title,
      photoPath: common.photoPath,
      description: common.description,
      rating: common.rating,
      review: common.review,
      happenedOn: common.happenedOn,
      franchiseId: json['franchiseId'] as int?,
      escaped: escaped,
      timeLeftMinutes: json['timeLeftMinutes'] as int?,
    );
  }

  static Meal _meal(Map<String, dynamic> json) {
    final common = _common(json, 'invalid-meal');

    return Meal(
      id: common.id,
      title: common.title,
      photoPath: common.photoPath,
      description: common.description,
      rating: common.rating,
      review: common.review,
      happenedOn: common.happenedOn,
      dish: json['dish'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      company: json['company'] as String?,
      location: json['location'] as String?,
    );
  }

  static Gig _gig(Map<String, dynamic> json) {
    final common = _common(json, 'invalid-gig');

    return Gig(
      id: common.id,
      title: common.title,
      photoPath: common.photoPath,
      description: common.description,
      rating: common.rating,
      review: common.review,
      happenedOn: common.happenedOn,
      venue: json['venue'] as String?,
      city: json['city'] as String?,
      supportActs: json['supportActs'] as String?,
      setlist: json['setlist'] as String?,
      company: json['company'] as String?,
      externalId: json['externalId'] as String?,
    );
  }

  static Viewing _viewing(Map<String, dynamic> json) {
    final common = _common(json, 'invalid-viewing');

    return Viewing(
      id: common.id,
      title: common.title,
      photoPath: common.photoPath,
      description: common.description,
      rating: common.rating,
      review: common.review,
      happenedOn: common.happenedOn,
      kind: _enumByName(json['kind'], ViewingKind.values, 'invalid-viewing'),
      releaseYear: json['releaseYear'] as int?,
      director: json['director'] as String?,
      cast: json['cast'] as String?,
      season: json['season'] as int?,
      externalId: json['externalId'] as String?,
    );
  }

  static Game _game(Map<String, dynamic> json) {
    final common = _common(json, 'invalid-game');

    return Game(
      id: common.id,
      title: common.title,
      photoPath: common.photoPath,
      description: common.description,
      rating: common.rating,
      review: common.review,
      happenedOn: common.happenedOn,
      status: _enumByName(json['status'], GameStatus.values, 'invalid-game'),
      platform: json['platform'] as String?,
      hoursPlayed: (json['hoursPlayed'] as num?)?.toDouble(),
      releaseYear: json['releaseYear'] as int?,
      externalId: json['externalId'] as String?,
    );
  }

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

/// The validated shared fields of one entry, on the way from JSON to a domain
/// object.
class _Common {
  const _Common({
    required this.id,
    required this.title,
    required this.photoPath,
    required this.description,
    required this.rating,
    required this.review,
    required this.happenedOn,
  });

  final int id;
  final String title;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final DateTime happenedOn;
}
