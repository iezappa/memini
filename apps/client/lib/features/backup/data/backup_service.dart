import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ids/uuid.dart';
import '../../books/domain/book.dart';
import '../../concerts/domain/gig.dart';
import '../../dining/domain/meal.dart';
import '../../franchises/domain/franchise.dart';
import '../../games/domain/game.dart';
import '../../rooms/domain/room.dart';
import '../../screen/domain/viewing.dart';
import '../../watchlist/domain/wish.dart';
import '../domain/backup_document.dart';
import '../domain/entries_csv.dart';

/// Reads and writes the whole database as one backup document.
///
/// Import is deliberately REPLACE-ONLY: merging two independent histories
/// would have to invent a conflict rule for every field, and a personal
/// tracker has no such rule. The caller must confirm before calling [import].
enum SyncEntryDisposition { newEntry, duplicate, conflict }

class SyncPreview {
  const SyncPreview({
    required this.newCount,
    required this.duplicateCount,
    required this.conflictCount,
    required this.invalidCount,
  });

  final int newCount;
  final int duplicateCount;
  final int conflictCount;
  final int invalidCount;

  int get totalCount =>
      newCount + duplicateCount + conflictCount + invalidCount;
  bool get hasChanges => newCount > 0;
}

typedef SyncApplyResult = SyncPreview;

class _SyncRecord<T> {
  const _SyncRecord({
    required this.id,
    required this.value,
    required this.fingerprint,
    required this.content,
  });

  final String id;
  final T value;
  final String fingerprint;
  final String content;
}

class _SyncIndex<T> {
  _SyncIndex(Iterable<_SyncRecord<T>> records)
    : byFingerprint = {
        for (final record in records) record.fingerprint: record,
      };

  final Map<String, _SyncRecord<T>> byFingerprint;

  SyncEntryDisposition classify(_SyncRecord<T> incoming) {
    final local = byFingerprint[incoming.fingerprint];
    if (local == null) return SyncEntryDisposition.newEntry;
    if (local.content == incoming.content) {
      return SyncEntryDisposition.duplicate;
    }
    return SyncEntryDisposition.conflict;
  }

  void add(_SyncRecord<T> record) {
    byFingerprint[record.fingerprint] = record;
  }
}

String _norm(Object? value) => (value?.toString() ?? '')
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'\s+'), ' ');

String _date(DateTime? value) => value == null
    ? ''
    : DateTime(value.year, value.month, value.day).toIso8601String();

String _content(Iterable<Object?> parts) => parts.map(_norm).join('|');

String _unusedId(String preferred, Set<String> used) {
  if (!used.contains(preferred)) return preferred;
  var id = newUuid();
  while (used.contains(id)) {
    id = newUuid();
  }
  return id;
}

Map<String, String> _franchiseNamesById(List<Franchise> franchises) => {
  for (final franchise in franchises) franchise.id: franchise.name,
};

List<_SyncRecord<Room>> _roomRecords(
  List<Room> entries,
  Map<String, String> franchiseNames,
) => [
  for (final entry in entries)
    _SyncRecord(
      id: entry.id,
      value: entry,
      fingerprint: _content([
        'room',
        entry.title,
        _date(entry.happenedOn),
        franchiseNames[entry.franchiseId],
      ]),
      content: _content([
        entry.title,
        entry.description,
        entry.rating,
        entry.review,
        _date(entry.happenedOn),
        entry.escaped,
        entry.timeLeftMinutes,
        franchiseNames[entry.franchiseId],
      ]),
    ),
];

List<_SyncRecord<Meal>> _mealRecords(List<Meal> entries) => [
  for (final entry in entries)
    _SyncRecord(
      id: entry.id,
      value: entry,
      fingerprint: _content([
        'meal',
        entry.title,
        _date(entry.happenedOn),
        entry.dish,
      ]),
      content: _content([
        entry.title,
        entry.description,
        entry.rating,
        entry.review,
        _date(entry.happenedOn),
        entry.dish,
        entry.price,
        entry.company,
        entry.mapsUrl,
      ]),
    ),
];

List<_SyncRecord<Gig>> _gigRecords(List<Gig> entries) => [
  for (final entry in entries)
    _SyncRecord(
      id: entry.id,
      value: entry,
      fingerprint: _content([
        'gig',
        entry.title,
        _date(entry.happenedOn),
        entry.venue,
        entry.city,
      ]),
      content: _content([
        entry.title,
        entry.description,
        entry.rating,
        entry.review,
        _date(entry.happenedOn),
        entry.venue,
        entry.city,
        entry.supportActs,
        entry.setlist,
        entry.company,
        entry.externalId,
        entry.photosUrl,
        entry.videoUrl,
      ]),
    ),
];

List<_SyncRecord<Viewing>> _viewingRecords(List<Viewing> entries) => [
  for (final entry in entries)
    _SyncRecord(
      id: entry.id,
      value: entry,
      fingerprint: _content([
        'viewing',
        entry.kind.name,
        entry.title,
        entry.releaseYear,
        entry.season,
        _date(entry.happenedOn),
      ]),
      content: _content([
        entry.title,
        entry.description,
        entry.rating,
        entry.review,
        _date(entry.happenedOn),
        entry.kind.name,
        entry.releaseYear,
        entry.director,
        entry.cast,
        entry.season,
        entry.externalId,
        entry.posterUrl,
        entry.backdropUrl,
      ]),
    ),
];

List<_SyncRecord<Game>> _gameRecords(List<Game> entries) => [
  for (final entry in entries)
    _SyncRecord(
      id: entry.id,
      value: entry,
      fingerprint: _content([
        'game',
        entry.title,
        _date(entry.happenedOn),
        entry.platform,
        entry.releaseYear,
      ]),
      content: _content([
        entry.title,
        entry.description,
        entry.rating,
        entry.review,
        _date(entry.happenedOn),
        entry.status.name,
        entry.platform,
        entry.hoursPlayed,
        entry.releaseYear,
        entry.externalId,
        entry.coverUrl,
      ]),
    ),
];

List<_SyncRecord<Book>> _bookRecords(List<Book> entries) => [
  for (final entry in entries)
    _SyncRecord(
      id: entry.id,
      value: entry,
      fingerprint: _content([
        'book',
        entry.title,
        entry.author,
        entry.publicationYear,
        _date(entry.readOn),
      ]),
      content: _content([
        entry.title,
        entry.description,
        entry.rating,
        entry.review,
        _date(entry.readOn),
        entry.author,
        entry.publicationYear,
        entry.externalId,
        entry.coverUrl,
      ]),
    ),
];

List<_SyncRecord<Wish>> _wishRecords(List<Wish> entries) => [
  for (final entry in entries)
    _SyncRecord(
      id: entry.id,
      value: entry,
      fingerprint: _content([
        'wish',
        entry.kind.name,
        entry.title,
        entry.releaseYear,
      ]),
      content: _content([
        entry.kind.name,
        entry.title,
        entry.note,
        entry.description,
        entry.releaseYear,
        entry.externalId,
        entry.posterUrl,
        _date(entry.addedOn),
      ]),
    ),
];

class BackupService {
  BackupService(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;

  /// Stamps a record restored without an updatedAt. Every record a v3 file or
  /// a parsed older file carries has one, so this is a last resort.
  final DateTime Function() _now;

  Future<BackupDocument> read() async {
    final franchiseRows = await _db.select(_db.franchises).get();
    final roomRows = await _db.select(_db.rooms).get();
    final mealRows = await _db.select(_db.meals).get();
    final gigRows = await _db.select(_db.gigs).get();
    final viewingRows = await _db.select(_db.viewings).get();
    final gameRows = await _db.select(_db.games).get();
    final bookRows = await _db.select(_db.books).get();
    final wishRows = await _db.select(_db.wishes).get();

    return BackupDocument.of(
      franchises: [
        for (final row in franchiseRows)
          Franchise(
            id: row.id,
            name: row.name,
            logoPath: row.logoPath,
            updatedAt: row.updatedAt,
          ),
      ],
      rooms: [
        for (final row in roomRows)
          Room(
            id: row.id,
            updatedAt: row.updatedAt,
            title: row.title,
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
            updatedAt: row.updatedAt,
            title: row.title,
            description: row.description,
            rating: row.rating,
            review: row.review,
            happenedOn: row.happenedOn,
            dish: row.dish,
            price: row.price,
            company: row.company,
            mapsUrl: row.mapsUrl,
          ),
      ],
      gigs: [
        for (final row in gigRows)
          Gig(
            id: row.id,
            updatedAt: row.updatedAt,
            title: row.title,
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
            photosUrl: row.photosUrl,
            videoUrl: row.videoUrl,
          ),
      ],
      viewings: [
        for (final row in viewingRows)
          Viewing(
            id: row.id,
            updatedAt: row.updatedAt,
            title: row.title,
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
            posterUrl: row.posterUrl,
            backdropUrl: row.backdropUrl,
          ),
      ],
      games: [
        for (final row in gameRows)
          Game(
            id: row.id,
            updatedAt: row.updatedAt,
            title: row.title,
            description: row.description,
            rating: row.rating,
            review: row.review,
            happenedOn: row.happenedOn,
            status: row.status,
            platform: row.platform,
            hoursPlayed: row.hoursPlayed,
            releaseYear: row.releaseYear,
            externalId: row.externalId,
            coverUrl: row.coverUrl,
          ),
      ],
      books: [
        for (final row in bookRows)
          Book(
            id: row.id,
            updatedAt: row.updatedAt,
            title: row.title,
            description: row.description,
            rating: row.rating,
            review: row.review,
            readOn: row.happenedOn,
            author: row.author,
            publicationYear: row.publicationYear,
            externalId: row.externalId,
            coverUrl: row.coverUrl,
          ),
      ],
      wishes: [
        for (final row in wishRows)
          Wish(
            id: row.id,
            kind: row.kind,
            title: row.title,
            addedOn: row.addedOn,
            updatedAt: row.updatedAt,
            note: row.note,
            description: row.description,
            releaseYear: row.releaseYear,
            externalId: row.externalId,
            posterUrl: row.posterUrl,
          ),
      ],
    );
  }

  Future<String> exportJson() async =>
      const JsonEncoder.withIndent('  ').convert((await read()).toJson());

  /// A sync package uses the same validated payload as a backup in phase 1.
  ///
  /// The operation is different on import: backup restore replaces everything,
  /// while sync import previews and only appends entries that are not already
  /// represented locally.
  Future<String> exportSyncJson() => exportJson();

  Future<SyncPreview> previewSync(BackupDocument incoming) async {
    final local = await read();
    return _compareSync(local: local, incoming: incoming);
  }

  Future<SyncApplyResult> applySync(BackupDocument incoming) async {
    final local = await read();
    final preview = _compareSync(local: local, incoming: incoming);
    if (!preview.hasChanges) return preview;

    await _db.transaction(() async {
      await _insertSyncNewEntries(local: local, incoming: incoming);
    });
    return preview;
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
      'books': booksToCsv(document.books),
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
      _db.wishes,
      _db.books,
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
    await _db.delete(_db.wishes).go();
    await _db.delete(_db.books).go();
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

  SyncPreview _compareSync({
    required BackupDocument local,
    required BackupDocument incoming,
  }) {
    var newCount = 0;
    var duplicateCount = 0;
    var conflictCount = 0;

    void count(SyncEntryDisposition disposition) {
      switch (disposition) {
        case SyncEntryDisposition.newEntry:
          newCount++;
          break;
        case SyncEntryDisposition.duplicate:
          duplicateCount++;
          break;
        case SyncEntryDisposition.conflict:
          conflictCount++;
          break;
      }
    }

    final localFranchises = _franchiseNamesById(local.franchises);
    final incomingFranchises = _franchiseNamesById(incoming.franchises);

    final roomIndex = _SyncIndex(_roomRecords(local.rooms, localFranchises));
    for (final record in _roomRecords(incoming.rooms, incomingFranchises)) {
      count(roomIndex.classify(record));
    }

    final mealIndex = _SyncIndex(_mealRecords(local.meals));
    for (final record in _mealRecords(incoming.meals)) {
      count(mealIndex.classify(record));
    }

    final gigIndex = _SyncIndex(_gigRecords(local.gigs));
    for (final record in _gigRecords(incoming.gigs)) {
      count(gigIndex.classify(record));
    }

    final viewingIndex = _SyncIndex(_viewingRecords(local.viewings));
    for (final record in _viewingRecords(incoming.viewings)) {
      count(viewingIndex.classify(record));
    }

    final gameIndex = _SyncIndex(_gameRecords(local.games));
    for (final record in _gameRecords(incoming.games)) {
      count(gameIndex.classify(record));
    }

    final bookIndex = _SyncIndex(_bookRecords(local.books));
    for (final record in _bookRecords(incoming.books)) {
      count(bookIndex.classify(record));
    }

    final wishIndex = _SyncIndex(_wishRecords(local.wishes));
    for (final record in _wishRecords(incoming.wishes)) {
      count(wishIndex.classify(record));
    }

    return SyncPreview(
      newCount: newCount,
      duplicateCount: duplicateCount,
      conflictCount: conflictCount,
      invalidCount: 0,
    );
  }

  Future<void> _insertSyncNewEntries({
    required BackupDocument local,
    required BackupDocument incoming,
  }) async {
    final localFranchiseNames = _franchiseNamesById(local.franchises);
    final incomingFranchiseNames = _franchiseNamesById(incoming.franchises);
    final franchiseIdByName = {
      for (final franchise in local.franchises)
        _norm(franchise.name): franchise.id,
    };
    final franchiseIds = {
      for (final franchise in local.franchises) franchise.id,
    };
    final franchiseRemap = <String, String>{};

    Future<String?> remapFranchise(String? incomingId) async {
      if (incomingId == null) return null;
      if (franchiseRemap.containsKey(incomingId)) {
        return franchiseRemap[incomingId];
      }
      final name = incomingFranchiseNames[incomingId];
      if (name == null) return null;
      final key = _norm(name);
      final existing = franchiseIdByName[key];
      if (existing != null) {
        franchiseRemap[incomingId] = existing;
        return existing;
      }
      final source = incoming.franchises.firstWhere((f) => f.id == incomingId);
      final id = _unusedId(source.id, franchiseIds);
      await _db
          .into(_db.franchises)
          .insert(
            FranchisesCompanion.insert(
              id: Value(id),
              updatedAt: source.updatedAt ?? _now(),
              name: source.name,
              logoPath: Value(source.logoPath),
            ),
          );
      franchiseIds.add(id);
      franchiseIdByName[key] = id;
      franchiseRemap[incomingId] = id;
      localFranchiseNames[id] = source.name;
      return id;
    }

    final roomIds = {for (final entry in local.rooms) entry.id};
    final mealIds = {for (final entry in local.meals) entry.id};
    final gigIds = {for (final entry in local.gigs) entry.id};
    final viewingIds = {for (final entry in local.viewings) entry.id};
    final gameIds = {for (final entry in local.games) entry.id};
    final bookIds = {for (final entry in local.books) entry.id};
    final wishIds = {for (final entry in local.wishes) entry.id};

    final roomIndex = _SyncIndex(
      _roomRecords(local.rooms, localFranchiseNames),
    );
    for (final record in _roomRecords(incoming.rooms, incomingFranchiseNames)) {
      if (roomIndex.classify(record) != SyncEntryDisposition.newEntry) continue;
      final r = record.value;
      final id = _unusedId(r.id, roomIds);
      final franchiseId = await remapFranchise(r.franchiseId);
      await _db
          .into(_db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: Value(id),
              updatedAt: r.updatedAt ?? _now(),
              title: r.title,
              description: Value(r.description),
              franchiseId: Value(franchiseId),
              rating: Value(r.rating),
              review: Value(r.review),
              happenedOn: r.happenedOn,
              escaped: r.escaped,
              timeLeftMinutes: Value(r.timeLeftMinutes),
            ),
          );
      roomIds.add(id);
      roomIndex.add(record);
    }

    final mealIndex = _SyncIndex(_mealRecords(local.meals));
    for (final record in _mealRecords(incoming.meals)) {
      if (mealIndex.classify(record) != SyncEntryDisposition.newEntry) continue;
      final m = record.value;
      final id = _unusedId(m.id, mealIds);
      await _db
          .into(_db.meals)
          .insert(
            MealsCompanion.insert(
              id: Value(id),
              updatedAt: m.updatedAt ?? _now(),
              title: m.title,
              description: Value(m.description),
              rating: Value(m.rating),
              review: Value(m.review),
              happenedOn: m.happenedOn,
              dish: Value(m.dish),
              price: Value(m.price),
              company: Value(m.company),
              mapsUrl: Value(m.mapsUrl),
            ),
          );
      mealIds.add(id);
      mealIndex.add(record);
    }

    final gigIndex = _SyncIndex(_gigRecords(local.gigs));
    for (final record in _gigRecords(incoming.gigs)) {
      if (gigIndex.classify(record) != SyncEntryDisposition.newEntry) continue;
      final g = record.value;
      final id = _unusedId(g.id, gigIds);
      await _db
          .into(_db.gigs)
          .insert(
            GigsCompanion.insert(
              id: Value(id),
              updatedAt: g.updatedAt ?? _now(),
              title: g.title,
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
              photosUrl: Value(g.photosUrl),
              videoUrl: Value(g.videoUrl),
            ),
          );
      gigIds.add(id);
      gigIndex.add(record);
    }

    final viewingIndex = _SyncIndex(_viewingRecords(local.viewings));
    for (final record in _viewingRecords(incoming.viewings)) {
      if (viewingIndex.classify(record) != SyncEntryDisposition.newEntry) {
        continue;
      }
      final v = record.value;
      final id = _unusedId(v.id, viewingIds);
      await _db
          .into(_db.viewings)
          .insert(
            ViewingsCompanion.insert(
              id: Value(id),
              updatedAt: v.updatedAt ?? _now(),
              title: v.title,
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
              posterUrl: Value(v.posterUrl),
              backdropUrl: Value(v.backdropUrl),
            ),
          );
      viewingIds.add(id);
      viewingIndex.add(record);
    }

    final gameIndex = _SyncIndex(_gameRecords(local.games));
    for (final record in _gameRecords(incoming.games)) {
      if (gameIndex.classify(record) != SyncEntryDisposition.newEntry) continue;
      final g = record.value;
      final id = _unusedId(g.id, gameIds);
      await _db
          .into(_db.games)
          .insert(
            GamesCompanion.insert(
              id: Value(id),
              updatedAt: g.updatedAt ?? _now(),
              title: g.title,
              description: Value(g.description),
              rating: Value(g.rating),
              review: Value(g.review),
              happenedOn: g.happenedOn,
              status: g.status,
              platform: Value(g.platform),
              hoursPlayed: Value(g.hoursPlayed),
              releaseYear: Value(g.releaseYear),
              externalId: Value(g.externalId),
              coverUrl: Value(g.coverUrl),
            ),
          );
      gameIds.add(id);
      gameIndex.add(record);
    }

    final bookIndex = _SyncIndex(_bookRecords(local.books));
    for (final record in _bookRecords(incoming.books)) {
      if (bookIndex.classify(record) != SyncEntryDisposition.newEntry) continue;
      final b = record.value;
      final id = _unusedId(b.id, bookIds);
      await _db
          .into(_db.books)
          .insert(
            BooksCompanion.insert(
              id: Value(id),
              updatedAt: b.updatedAt ?? _now(),
              title: b.title,
              description: Value(b.description),
              rating: Value(b.rating),
              review: Value(b.review),
              happenedOn: b.readOn,
              author: Value(b.author),
              publicationYear: Value(b.publicationYear),
              externalId: Value(b.externalId),
              coverUrl: Value(b.coverUrl),
            ),
          );
      bookIds.add(id);
      bookIndex.add(record);
    }

    final wishIndex = _SyncIndex(_wishRecords(local.wishes));
    for (final record in _wishRecords(incoming.wishes)) {
      if (wishIndex.classify(record) != SyncEntryDisposition.newEntry) continue;
      final w = record.value;
      final id = _unusedId(w.id, wishIds);
      await _db
          .into(_db.wishes)
          .insert(
            WishesCompanion.insert(
              id: Value(id),
              kind: w.kind,
              title: w.title,
              addedOn: w.addedOn,
              updatedAt: w.updatedAt ?? _now(),
              note: Value(w.note),
              description: Value(w.description),
              releaseYear: Value(w.releaseYear),
              externalId: Value(w.externalId),
              posterUrl: Value(w.posterUrl),
            ),
          );
      wishIds.add(id);
      wishIndex.add(record);
    }
  }

  /// Replaces everything stored with [document], in one transaction.
  Future<void> restore(BackupDocument document) async {
    await _db.transaction(() async {
      await _deleteAll();

      // Insert row-by-row instead of one large batch. The web SQLite backend is
      // more sensitive to large batch payloads, and a restore should prefer a
      // slower, predictable transaction over a backend-specific bulk failure.
      for (final f in document.franchises) {
        await _db
            .into(_db.franchises)
            .insert(
              FranchisesCompanion.insert(
                id: Value(f.id),
                updatedAt: f.updatedAt ?? _now(),
                name: f.name,
                logoPath: Value(f.logoPath),
              ),
            );
      }
      for (final r in document.rooms) {
        await _db
            .into(_db.rooms)
            .insert(
              RoomsCompanion.insert(
                id: Value(r.id),
                updatedAt: r.updatedAt ?? _now(),
                title: r.title,
                description: Value(r.description),
                franchiseId: Value(r.franchiseId),
                rating: Value(r.rating),
                review: Value(r.review),
                happenedOn: r.happenedOn,
                escaped: r.escaped,
                timeLeftMinutes: Value(r.timeLeftMinutes),
              ),
            );
      }
      for (final m in document.meals) {
        await _db
            .into(_db.meals)
            .insert(
              MealsCompanion.insert(
                id: Value(m.id),
                updatedAt: m.updatedAt ?? _now(),
                title: m.title,
                description: Value(m.description),
                rating: Value(m.rating),
                review: Value(m.review),
                happenedOn: m.happenedOn,
                dish: Value(m.dish),
                price: Value(m.price),
                company: Value(m.company),
                mapsUrl: Value(m.mapsUrl),
              ),
            );
      }
      for (final g in document.gigs) {
        await _db
            .into(_db.gigs)
            .insert(
              GigsCompanion.insert(
                id: Value(g.id),
                updatedAt: g.updatedAt ?? _now(),
                title: g.title,
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
                photosUrl: Value(g.photosUrl),
                videoUrl: Value(g.videoUrl),
              ),
            );
      }
      for (final v in document.viewings) {
        await _db
            .into(_db.viewings)
            .insert(
              ViewingsCompanion.insert(
                id: Value(v.id),
                updatedAt: v.updatedAt ?? _now(),
                title: v.title,
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
                posterUrl: Value(v.posterUrl),
                backdropUrl: Value(v.backdropUrl),
              ),
            );
      }
      for (final g in document.games) {
        await _db
            .into(_db.games)
            .insert(
              GamesCompanion.insert(
                id: Value(g.id),
                updatedAt: g.updatedAt ?? _now(),
                title: g.title,
                description: Value(g.description),
                rating: Value(g.rating),
                review: Value(g.review),
                happenedOn: g.happenedOn,
                status: g.status,
                platform: Value(g.platform),
                hoursPlayed: Value(g.hoursPlayed),
                releaseYear: Value(g.releaseYear),
                externalId: Value(g.externalId),
                coverUrl: Value(g.coverUrl),
              ),
            );
      }
      for (final b in document.books) {
        await _db
            .into(_db.books)
            .insert(
              BooksCompanion.insert(
                id: Value(b.id),
                updatedAt: b.updatedAt ?? _now(),
                title: b.title,
                description: Value(b.description),
                rating: Value(b.rating),
                review: Value(b.review),
                happenedOn: b.readOn,
                author: Value(b.author),
                publicationYear: Value(b.publicationYear),
                externalId: Value(b.externalId),
                coverUrl: Value(b.coverUrl),
              ),
            );
      }
      for (final w in document.wishes) {
        await _db
            .into(_db.wishes)
            .insert(
              WishesCompanion.insert(
                id: Value(w.id),
                kind: w.kind,
                title: w.title,
                addedOn: w.addedOn,
                updatedAt: w.updatedAt ?? _now(),
                note: Value(w.note),
                description: Value(w.description),
                releaseYear: Value(w.releaseYear),
                externalId: Value(w.externalId),
                posterUrl: Value(w.posterUrl),
              ),
            );
      }
    });
  }
}
