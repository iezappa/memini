import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tracking/data/tracking_query.dart';
import '../../../core/tracking/domain/tracking_filter.dart';
import '../domain/room.dart';
import '../domain/room_repository.dart';

class DriftRoomRepository implements RoomRepository {
  DriftRoomRepository(this._db);

  final AppDatabase _db;

  TrackingColumns get _columns {
    final rooms = _db.rooms;
    return TrackingColumns(
      id: rooms.id,
      title: rooms.title,
      description: rooms.description,
      review: rooms.review,
      rating: rooms.rating,
      happenedOn: rooms.happenedOn,
    );
  }

  Room _toDomain(RoomRow row) => Room(
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
  );

  SimpleSelectStatement<$RoomsTable, RoomRow> _query(RoomFilter filter) {
    final rooms = _db.rooms;
    final query = _db.select(rooms);

    final shared = trackingPredicate(_columns, filter);
    if (shared != null) query.where((_) => shared);

    if (filter.franchiseId != null) {
      query.where((r) => r.franchiseId.equals(filter.franchiseId!));
    }
    if (filter.escaped != null) {
      query.where((r) => r.escaped.equals(filter.escaped!));
    }

    final ordering = trackingOrdering(_columns, filter.sort);
    query.orderBy([for (final term in ordering) (_) => term]);

    return query;
  }

  @override
  Future<List<Room>> list(RoomFilter filter) async =>
      (await _query(filter).get()).map(_toDomain).toList();

  @override
  Stream<List<Room>> watch(RoomFilter filter) =>
      _query(filter).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Room?> findById(int id) async {
    final row = await (_db.select(
      _db.rooms,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Room> create(RoomDraft draft) async {
    final row = await _db
        .into(_db.rooms)
        .insertReturning(
          RoomsCompanion.insert(
            title: draft.title.trim(),
            happenedOn: dayOf(draft.happenedOn),
            escaped: draft.escaped,
            photoPath: Value(draft.photoPath),
            description: Value(draft.description),
            franchiseId: Value(draft.franchiseId),
            rating: Value(draft.rating),
            review: Value(draft.review),
            timeLeftMinutes: Value(draft.timeLeftMinutes),
          ),
        );
    return _toDomain(row);
  }

  @override
  Future<void> update(Room entry) async {
    await (_db.update(_db.rooms)..where((r) => r.id.equals(entry.id))).write(
      RoomsCompanion(
        title: Value(entry.title.trim()),
        photoPath: Value(entry.photoPath),
        description: Value(entry.description),
        franchiseId: Value(entry.franchiseId),
        rating: Value(entry.rating),
        review: Value(entry.review),
        happenedOn: Value(dayOf(entry.happenedOn)),
        escaped: Value(entry.escaped),
        timeLeftMinutes: Value(entry.timeLeftMinutes),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.rooms)..where((r) => r.id.equals(id))).go();
  }
}
