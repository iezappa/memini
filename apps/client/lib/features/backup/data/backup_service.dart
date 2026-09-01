import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../concerts/domain/gig.dart';
import '../../dining/domain/meal.dart';
import '../../franchises/domain/franchise.dart';
import '../../games/domain/game.dart';
import '../../rooms/domain/room.dart';
import '../../screen/domain/viewing.dart';
import '../domain/backup_document.dart';
import '../domain/entries_csv.dart';

/// Reads and writes the whole database as one backup document.
///
/// Import is deliberately REPLACE-ONLY: merging two independent histories
/// would have to invent a conflict rule for every field, and a personal
/// tracker has no such rule. The caller must confirm before calling [import].
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

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

  Future<String> exportJson() async =>
      const JsonEncoder.withIndent('  ').convert((await read()).toJson());

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
    final Object? decoded;
    try {
      decoded = jsonDecode(contents);
    } on FormatException {
      throw const BackupFormatException('not-json');
    }

    final document = BackupDocument.fromJson(decoded);

    await _db.transaction(() async {
      // Rooms first: they reference franchises, and the foreign key would
      // block deleting a franchise that still has rooms pointing at it.
      await _db.delete(_db.rooms).go();
      await _db.delete(_db.franchises).go();
      await _db.delete(_db.meals).go();
      await _db.delete(_db.gigs).go();
      await _db.delete(_db.viewings).go();
      await _db.delete(_db.games).go();

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

    return document;
  }
}
