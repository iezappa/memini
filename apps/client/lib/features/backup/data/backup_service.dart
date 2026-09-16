import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../concerts/domain/gig.dart';
import '../../dining/domain/meal.dart';
import '../../franchises/domain/franchise.dart';
import '../../games/domain/game.dart';
import '../../rooms/domain/room.dart';
import '../../screen/domain/viewing.dart';
import '../../shared/photo_storage.dart';
import '../domain/backup_archive.dart';
import '../domain/backup_document.dart';
import '../domain/entries_csv.dart';

/// Reads and writes the whole database as one backup document.
///
/// Import is deliberately REPLACE-ONLY: merging two independent histories
/// would have to invent a conflict rule for every field, and a personal
/// tracker has no such rule. The caller must confirm before calling [import].
class BackupService {
  BackupService(this._db, {this._photos = const PhotoStorage()});

  final AppDatabase _db;
  final PhotoStorage _photos;

  Future<BackupDocument> read() async {
    final franchiseRows = await _db.select(_db.franchises).get();
    final roomRows = await _db.select(_db.rooms).get();
    final mealRows = await _db.select(_db.meals).get();
    final gigRows = await _db.select(_db.gigs).get();
    final viewingRows = await _db.select(_db.viewings).get();
    final gameRows = await _db.select(_db.games).get();

    return BackupDocument.of(
      franchises: [
        for (final row in franchiseRows)
          Franchise(id: row.id, name: row.name, logoPath: row.logoPath),
      ],
      rooms: [
        for (final row in roomRows)
          Room(
            id: row.id,
            title: row.title,
            photoPath: row.photoPath,
            description: row.description,
            franchiseId: row.franchiseId,
            rating: row.rating,
            review: row.review,
            happenedOn: row.happenedOn,
            escaped: row.escaped,
            timeLeftMinutes: row.timeLeftMinutes,
          ),
      ],
      meals: [
        for (final row in mealRows)
          Meal(
            id: row.id,
            title: row.title,
            photoPath: row.photoPath,
            description: row.description,
            rating: row.rating,
            review: row.review,
            happenedOn: row.happenedOn,
            dish: row.dish,
            price: row.price,
            company: row.company,
            location: row.location,
          ),
      ],
      gigs: [
        for (final row in gigRows)
          Gig(
            id: row.id,
            title: row.title,
            photoPath: row.photoPath,
            description: row.description,
            rating: row.rating,
            review: row.review,
            happenedOn: row.happenedOn,
            venue: row.venue,
            city: row.city,
            supportActs: row.supportActs,
            setlist: row.setlist,
            company: row.company,
            externalId: row.externalId,
          ),
      ],
      viewings: [
        for (final row in viewingRows)
          Viewing(
            id: row.id,
            title: row.title,
            photoPath: row.photoPath,
            description: row.description,
            rating: row.rating,
            review: row.review,
            happenedOn: row.happenedOn,
            kind: row.kind,
            releaseYear: row.releaseYear,
            director: row.director,
            cast: row.cast,
            season: row.season,
            externalId: row.externalId,
          ),
      ],
      games: [
        for (final row in gameRows)
          Game(
            id: row.id,
            title: row.title,
            photoPath: row.photoPath,
            description: row.description,
            rating: row.rating,
            review: row.review,
            happenedOn: row.happenedOn,
            status: row.status,
            platform: row.platform,
            hoursPlayed: row.hoursPlayed,
            releaseYear: row.releaseYear,
            externalId: row.externalId,
          ),
      ],
    );
  }

  Future<String> exportJson() async => _encode((await read()).toJson());

  static String _encode(Map<String, dynamic> json) =>
      const JsonEncoder.withIndent('  ').convert(json);

  /// The full backup as one zip: the document and every photo it can find.
  ///
  /// A photo whose file is gone is left out and counted rather than failing
  /// the export: the rest of the record is worth more than one missing image.
  Future<BackupExport> exportArchive() async {
    final json = (await read()).toJson();
    final photos = <String, Uint8List>{};
    var missing = 0;

    for (final entry in _entriesOf(json)) {
      final path = entry['photoPath'] as String?;
      if (path == null) continue;

      final bytes = await _photos.read(path);
      if (bytes == null) {
        entry['photoPath'] = null;
        missing++;
        continue;
      }
      final name =
          '${BackupArchive.photoFolder}${photos.length}${_extensionOf(path)}';
      photos[name] = bytes;
      entry['photoPath'] = name;
    }

    return BackupExport(
      bytes: BackupArchive.encode(_encode(json), photos),
      missingPhotos: missing,
    );
  }

  static Iterable<Map<String, dynamic>> _entriesOf(Map<String, dynamic> json) =>
      [
        for (final list in BackupArchive.entryLists)
          ...((json[list] as List<dynamic>?) ?? const [])
              .cast<Map<String, dynamic>>(),
      ];

  static String _extensionOf(String path) {
    final name = path.split(RegExp(r'[/\\]')).last;
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || name.length - dot > 5) return '.jpg';
    return name.substring(dot);
  }

  /// Reads a backup file — a zip with photos, or an older plain JSON file —
  /// and validates it without touching anything stored.
  static ParsedBackup parseFile(List<int> bytes) {
    if (BackupArchive.looksLikeZip(bytes)) {
      final (:json, :photos) = BackupArchive.decode(bytes);
      return ParsedBackup._(_decodeObject(json), photos, fromArchive: true);
    }

    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      throw const BackupFormatException('not-json');
    }
    return ParsedBackup._(_decodeObject(text), const {}, fromArchive: false);
  }

  static Map<String, dynamic> _decodeObject(String contents) {
    final Object? decoded;
    try {
      decoded = jsonDecode(contents);
    } on FormatException {
      throw const BackupFormatException('not-json');
    }
    // Validates the whole document up front; the result is rebuilt after the
    // photos have somewhere to live.
    BackupDocument.fromJson(decoded);
    return decoded! as Map<String, dynamic>;
  }

  /// Parses and restores a backup file. See [parseFile] and [restoreParsed].
  Future<BackupDocument> importFile(List<int> bytes) async =>
      restoreParsed(parseFile(bytes));

  /// Stores the photos a parsed backup carries, then replaces everything.
  ///
  /// Photos go in first, so the rows can point at them. Once the rows are in,
  /// the photos of the data that was replaced are deleted.
  Future<BackupDocument> restoreParsed(ParsedBackup backup) async {
    final json = backup._json;
    if (backup.fromArchive) {
      for (final entry in _entriesOf(json)) {
        final name = entry['photoPath'] as String?;
        final bytes = name == null ? null : backup._photos[name];
        entry['photoPath'] = bytes == null
            ? null
            : await _photos.storeBytes(bytes, extension: _extensionOf(name!));
      }
    }

    final document = BackupDocument.fromJson(json);
    await restore(document);
    try {
      await _photos.removeAllExcept({
        for (final entry in _entriesOf(json))
          if (entry['photoPath'] case final String path) path,
      });
    } on Object {
      // Housekeeping only: the restore itself is already in, and a leftover
      // file is harmless. The next restore gets another chance at it.
    }
    return document;
  }

  /// One CSV file per domain, keyed by a file-name stem.
  ///
  /// Five domains cannot share a header without inventing empty columns for
  /// every field the others do not have, so they stay five sheets.
  Future<Map<String, String>> exportCsv() async {
    final document = await read();
    return {
      'rooms': roomsToCsv(
        rooms: document.rooms,
        franchises: document.franchises,
      ),
      'meals': mealsToCsv(document.meals),
      'gigs': gigsToCsv(document.gigs),
      'viewings': viewingsToCsv(document.viewings),
      'games': gamesToCsv(document.games),
    };
  }

  /// Parses [contents] and, only if the whole document is valid, replaces
  /// everything currently stored. Throws [BackupFormatException] otherwise,
  /// leaving the database untouched.
  Future<BackupDocument> import(String contents) async {
    final document = parse(contents);
    await restore(document);
    return document;
  }

  /// Whether anything at all has been recorded.
  Future<bool> holdsUserData() async {
    for (final table in <TableInfo<Table, Object?>>[
      _db.franchises,
      _db.rooms,
      _db.meals,
      _db.gigs,
      _db.viewings,
      _db.games,
    ]) {
      final row = await _db
          .customSelect(
            'SELECT EXISTS(SELECT 1 FROM "${table.actualTableName}") AS present',
          )
          .getSingle();
      if (row.read<int>('present') == 1) return true;
    }
    return false;
  }

  /// Empties every table in one transaction. Memini ships no seed rows, so
  /// there is nothing to put back.
  Future<void> eraseEverything() => _db.transaction(_deleteAll);

  Future<void> _deleteAll() async {
    // Rooms first: they reference franchises, and the foreign key would
    // block deleting a franchise that still has rooms pointing at it.
    await _db.delete(_db.rooms).go();
    await _db.delete(_db.franchises).go();
    await _db.delete(_db.meals).go();
    await _db.delete(_db.gigs).go();
    await _db.delete(_db.viewings).go();
    await _db.delete(_db.games).go();
  }

  /// Decodes and validates [contents] without touching the database, so a
  /// caller can refuse a bad file before deleting anything.
  static BackupDocument parse(String contents) {
    final Object? decoded;
    try {
      decoded = jsonDecode(contents);
    } on FormatException {
      throw const BackupFormatException('not-json');
    }
    return BackupDocument.fromJson(decoded);
  }

  /// Replaces everything stored with [document], in one transaction.
  Future<void> restore(BackupDocument document) async {
    await _db.transaction(() async {
      await _deleteAll();

      await _db.batch((batch) {
        batch.insertAll(_db.franchises, [
          for (final f in document.franchises)
            FranchisesCompanion.insert(
              id: Value(f.id),
              name: f.name,
              logoPath: Value(f.logoPath),
            ),
        ]);
        batch.insertAll(_db.rooms, [
          for (final r in document.rooms)
            RoomsCompanion.insert(
              id: Value(r.id),
              title: r.title,
              photoPath: Value(r.photoPath),
              description: Value(r.description),
              franchiseId: Value(r.franchiseId),
              rating: Value(r.rating),
              review: Value(r.review),
              happenedOn: r.happenedOn,
              escaped: r.escaped,
              timeLeftMinutes: Value(r.timeLeftMinutes),
            ),
        ]);
        batch.insertAll(_db.meals, [
          for (final m in document.meals)
            MealsCompanion.insert(
              id: Value(m.id),
              title: m.title,
              photoPath: Value(m.photoPath),
              description: Value(m.description),
              rating: Value(m.rating),
              review: Value(m.review),
              happenedOn: m.happenedOn,
              dish: Value(m.dish),
              price: Value(m.price),
              company: Value(m.company),
              location: Value(m.location),
            ),
        ]);
        batch.insertAll(_db.gigs, [
          for (final g in document.gigs)
            GigsCompanion.insert(
              id: Value(g.id),
              title: g.title,
              photoPath: Value(g.photoPath),
              description: Value(g.description),
              rating: Value(g.rating),
              review: Value(g.review),
              happenedOn: g.happenedOn,
              venue: Value(g.venue),
              city: Value(g.city),
              supportActs: Value(g.supportActs),
              setlist: Value(g.setlist),
              company: Value(g.company),
              externalId: Value(g.externalId),
            ),
        ]);
        batch.insertAll(_db.viewings, [
          for (final v in document.viewings)
            ViewingsCompanion.insert(
              id: Value(v.id),
              title: v.title,
              photoPath: Value(v.photoPath),
              description: Value(v.description),
              rating: Value(v.rating),
              review: Value(v.review),
              happenedOn: v.happenedOn,
              kind: v.kind,
              releaseYear: Value(v.releaseYear),
              director: Value(v.director),
              cast: Value(v.cast),
              season: Value(v.season),
              externalId: Value(v.externalId),
            ),
        ]);
        batch.insertAll(_db.games, [
          for (final g in document.games)
            GamesCompanion.insert(
              id: Value(g.id),
              title: g.title,
              photoPath: Value(g.photoPath),
              description: Value(g.description),
              rating: Value(g.rating),
              review: Value(g.review),
              happenedOn: g.happenedOn,
              status: g.status,
              platform: Value(g.platform),
              hoursPlayed: Value(g.hoursPlayed),
              releaseYear: Value(g.releaseYear),
              externalId: Value(g.externalId),
            ),
        ]);
      });
    });
  }
}

/// A finished export: the file, and how many photos had to be left out.
class BackupExport {
  const BackupExport({required this.bytes, required this.missingPhotos});

  final Uint8List bytes;
  final int missingPhotos;
}

/// A backup file that has been read and validated, not yet restored.
class ParsedBackup {
  const ParsedBackup._(this._json, this._photos, {required this.fromArchive});

  final Map<String, dynamic> _json;
  final Map<String, Uint8List> _photos;

  /// A zip, whose photo paths name files inside it.
  final bool fromArchive;
}
