import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tracking/data/tracking_query.dart';
import '../../../core/tracking/domain/tracking_filter.dart';
import '../domain/game.dart';
import '../domain/game_repository.dart';

class DriftGameRepository implements GameRepository {
  DriftGameRepository(this._db);

  final AppDatabase _db;

  TrackingColumns get _columns {
    final games = _db.games;
    return TrackingColumns(
      id: games.id,
      title: games.title,
      description: games.description,
      review: games.review,
      rating: games.rating,
      happenedOn: games.happenedOn,
    );
  }

  Game _toDomain(GameRow row) => Game(
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
  );

  SimpleSelectStatement<$GamesTable, GameRow> _query(GameFilter filter) {
    final query = _db.select(_db.games);

    final shared = trackingPredicate(_columns, filter);
    if (shared != null) query.where((_) => shared);

    if (filter.status != null) {
      query.where((g) => g.status.equalsValue(filter.status!));
    }

    final platform = filter.platform?.trim();
    if (platform != null && platform.isNotEmpty) {
      final pattern = '%${platform.toLowerCase()}%';
      query.where((g) => g.platform.lower().like(pattern));
    }

    final ordering = trackingOrdering(_columns, filter.sort);
    query.orderBy([for (final term in ordering) (_) => term]);

    return query;
  }

  @override
  Future<List<Game>> list(GameFilter filter) async =>
      (await _query(filter).get()).map(_toDomain).toList();

  @override
  Stream<List<Game>> watch(GameFilter filter) =>
      _query(filter).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Game?> findById(int id) async {
    final row = await (_db.select(
      _db.games,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Game> create(GameDraft draft) async {
    final row = await _db
        .into(_db.games)
        .insertReturning(
          GamesCompanion.insert(
            title: draft.title.trim(),
            happenedOn: dayOf(draft.happenedOn),
            status: draft.status,
            photoPath: Value(draft.photoPath),
            description: Value(draft.description),
            rating: Value(draft.rating),
            review: Value(draft.review),
            platform: Value(draft.platform),
            hoursPlayed: Value(draft.hoursPlayed),
            releaseYear: Value(draft.releaseYear),
            externalId: Value(draft.externalId),
          ),
        );
    return _toDomain(row);
  }

  @override
  Future<void> update(Game entry) async {
    await (_db.update(_db.games)..where((g) => g.id.equals(entry.id))).write(
      GamesCompanion(
        title: Value(entry.title.trim()),
        photoPath: Value(entry.photoPath),
        description: Value(entry.description),
        rating: Value(entry.rating),
        review: Value(entry.review),
        happenedOn: Value(dayOf(entry.happenedOn)),
        status: Value(entry.status),
        platform: Value(entry.platform),
        hoursPlayed: Value(entry.hoursPlayed),
        releaseYear: Value(entry.releaseYear),
        externalId: Value(entry.externalId),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.games)..where((g) => g.id.equals(id))).go();
  }
}
