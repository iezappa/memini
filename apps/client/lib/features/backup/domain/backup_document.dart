library;

import '../../../core/ids/uuid.dart';
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
  ///
  /// v3 carries UUID ids and an updatedAt on every record (schema v4). A v1
  /// or v2 file, with integer ids, is given fresh UUIDs on import and its
  /// room-to-franchise links are remapped onto them.
  static const currentVersion = 3;

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
        {
          'id': f.id,
          'name': f.name,
          'logoPath': f.logoPath,
          'updatedAt': _instant(f.updatedAt),
        },
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
    'description': entry.description,
    'rating': entry.rating,
    'review': entry.review,
    'happenedOn': _dateOnly(entry.happenedOn),
    'updatedAt': _instant(entry.updatedAt),
  };

  static String? _instant(DateTime? value) => value?.toUtc().toIso8601String();

  /// Validates the whole document before returning it, so a malformed file
  /// can never be half-applied to the database.
  ///
  /// [newId] mints the UUIDs given to records of a pre-v3 file.
  factory BackupDocument.fromJson(Object? raw, {String Function()? newId}) {
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

    final reader = version < 3
        ? _LegacyIds(newId ?? newUuid, exportedAt)
        : const _UuidIds();

    final franchiseIds = reader.scope('invalid-franchise');
    final franchises = [
      for (final json in _listOf(raw['franchises']))
        _franchise(json, franchiseIds, reader),
    ];

    final roomIds = reader.scope('invalid-room');
    final rooms = [
      for (final json in _listOf(raw['rooms']))
        _room(json, roomIds, franchiseIds, reader),
    ];

    final mealIds = reader.scope('invalid-meal');
    final gigIds = reader.scope('invalid-gig');
    final viewingIds = reader.scope('invalid-viewing');
    final gameIds = reader.scope('invalid-game');

    return BackupDocument(
      version: version,
      exportedAt: exportedAt,
      franchises: franchises,
      rooms: rooms,
      meals: [
        for (final json in _listOf(raw['meals'])) _meal(json, mealIds, reader),
      ],
      gigs: [
        for (final json in _listOf(raw['gigs'])) _gig(json, gigIds, reader),
      ],
      viewings: [
        for (final json in _listOf(raw['viewings']))
          _viewing(json, viewingIds, reader),
      ],
      games: [
        for (final json in _listOf(raw['games'])) _game(json, gameIds, reader),
      ],
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

  static Franchise _franchise(
    Map<String, dynamic> json,
    _IdScope ids,
    _IdReader reader,
  ) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const BackupFormatException('invalid-franchise');
    }
    return Franchise(
      id: ids.declare(json['id']),
      name: name,
      logoPath: json['logoPath'] as String?,
      updatedAt: reader.updatedAt(json['updatedAt'], 'invalid-franchise'),
    );
  }

  /// The fields every entry shares, validated once instead of five times.
  static _Common _common(
    Map<String, dynamic> json,
    String reason,
    _IdScope ids,
    _IdReader reader,
  ) {
    final title = json['title'];
    final happenedOn = DateTime.tryParse(json['happenedOn'] as String? ?? '');

    if (title is! String || title.trim().isEmpty || happenedOn == null) {
      throw BackupFormatException(reason);
    }

    final rating = (json['rating'] as num?)?.toDouble();
    if (rating != null && (rating < kMinRating || rating > kMaxRating)) {
      throw const BackupFormatException('rating-out-of-range');
    }

    return _Common(
      id: ids.declare(json['id']),
      updatedAt: reader.updatedAt(json['updatedAt'], reason),
      title: title,
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

  static Room _room(
    Map<String, dynamic> json,
    _IdScope ids,
    _IdScope franchiseIds,
    _IdReader reader,
  ) {
    final common = _common(json, 'invalid-room', ids, reader);
    final escaped = json['escaped'];
    if (escaped is! bool) throw const BackupFormatException('invalid-room');

    return Room(
      id: common.id,
      updatedAt: common.updatedAt,
      title: common.title,
      description: common.description,
      rating: common.rating,
      review: common.review,
      happenedOn: common.happenedOn,
      franchiseId: franchiseIds.reference(json['franchiseId']),
      escaped: escaped,
      timeLeftMinutes: json['timeLeftMinutes'] as int?,
    );
  }

  static Meal _meal(Map<String, dynamic> json, _IdScope ids, _IdReader reader) {
    final common = _common(json, 'invalid-meal', ids, reader);

    return Meal(
      id: common.id,
      updatedAt: common.updatedAt,
      title: common.title,
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

  static Gig _gig(Map<String, dynamic> json, _IdScope ids, _IdReader reader) {
    final common = _common(json, 'invalid-gig', ids, reader);

    return Gig(
      id: common.id,
      updatedAt: common.updatedAt,
      title: common.title,
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

  static Viewing _viewing(
    Map<String, dynamic> json,
    _IdScope ids,
    _IdReader reader,
  ) {
    final common = _common(json, 'invalid-viewing', ids, reader);

    return Viewing(
      id: common.id,
      updatedAt: common.updatedAt,
      title: common.title,
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

  static Game _game(Map<String, dynamic> json, _IdScope ids, _IdReader reader) {
    final common = _common(json, 'invalid-game', ids, reader);

    return Game(
      id: common.id,
      updatedAt: common.updatedAt,
      title: common.title,
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
    required this.updatedAt,
    required this.title,
    required this.description,
    required this.rating,
    required this.review,
    required this.happenedOn,
  });

  final String id;
  final DateTime updatedAt;
  final String title;
  final String? description;
  final double? rating;
  final String? review;
  final DateTime happenedOn;
}

/// How record ids and timestamps are read, which depends on the file version.
sealed class _IdReader {
  const _IdReader();

  /// A fresh id namespace for one kind of record.
  _IdScope scope(String reason);

  DateTime updatedAt(Object? raw, String reason);
}

/// v3 onwards: ids are UUIDs and every record says when it was last written.
class _UuidIds extends _IdReader {
  const _UuidIds();

  @override
  _IdScope scope(String reason) => _IdScope(reason, (raw) {
    if (raw is String && isUuid(raw)) return raw;
    throw BackupFormatException(reason);
  });

  @override
  DateTime updatedAt(Object? raw, String reason) {
    final parsed = raw is String ? DateTime.tryParse(raw) : null;
    if (parsed == null) throw BackupFormatException(reason);
    return parsed;
  }
}

/// v1 and v2: integer ids, no timestamps.
///
/// Each integer is given a new UUID, per kind of record, and a reference is
/// resolved through the same table, so a room still points at its franchise.
/// The export date is the best known bound for when a record last changed.
class _LegacyIds extends _IdReader {
  _LegacyIds(this._newId, this._exportedAt);

  final String Function() _newId;
  final DateTime _exportedAt;

  @override
  _IdScope scope(String reason) => _IdScope(reason, (raw) {
    if (raw is int) return _newId();
    throw BackupFormatException(reason);
  }, keyOf: (raw) => raw);

  @override
  DateTime updatedAt(Object? raw, String reason) => _exportedAt;
}

/// The ids declared by one kind of record, and the lookups into them.
class _IdScope {
  _IdScope(this._reason, this._mint, {this.keyOf});

  final String _reason;
  final String Function(Object? raw) _mint;

  /// What a raw id is looked up by; null means the minted id itself.
  final Object? Function(Object? raw)? keyOf;
  final _ids = <Object?, String>{};

  /// Registers a record's id, refusing a duplicate.
  String declare(Object? raw) {
    final id = _mint(raw);
    final key = keyOf == null ? id : keyOf!(raw);
    if (_ids.containsKey(key)) throw BackupFormatException(_reason);
    _ids[key] = id;
    return id;
  }

  /// Resolves a reference to a record declared earlier in this scope.
  String? reference(Object? raw) {
    if (raw == null) return null;
    final id = _ids[raw];
    if (id == null) {
      throw const BackupFormatException('dangling-franchise-reference');
    }
    return id;
  }
}
