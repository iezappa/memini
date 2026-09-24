
import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../ids/uuid.dart';
import '../domain/entry_photo.dart';

/// Drift-backed implementation of [PhotoRepository].
class DriftPhotoRepository implements PhotoRepository {
  DriftPhotoRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Future<List<EntryPhoto>> forOwner(String ownerId) async {
    final rows =
        await (_db.select(_db.entryPhotos)
              ..where((p) => p.ownerId.equals(ownerId))
              ..orderBy([(p) => OrderingTerm.asc(p.updatedAt)]))
            .get();

    return [for (final row in rows) _photoOf(row)];
  }

  EntryPhoto _photoOf(EntryPhotoRow row) => EntryPhoto(
    id: row.id,
    ownerId: row.ownerId,
    bytes: row.bytes,
    mimeType: row.mimeType,
  );

  @override
  Future<List<EntryPhoto>> all() async {
    final rows = await (_db.select(
      _db.entryPhotos,
    )..orderBy([(p) => OrderingTerm.asc(p.updatedAt)])).get();

    return [for (final row in rows) _photoOf(row)];
  }

  @override
  Future<EntryPhoto?> coverFor(String ownerId) async {
    final row =
        await (_db.select(_db.entryPhotos)
              ..where((p) => p.ownerId.equals(ownerId))
              ..orderBy([(p) => OrderingTerm.asc(p.updatedAt)])
              ..limit(1))
            .getSingleOrNull();

    return row == null ? null : _photoOf(row);
  }

  @override
  Future<EntryPhoto> add({
    required String ownerId,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final photo = EntryPhoto(
      id: newUuid(),
      ownerId: ownerId,
      bytes: bytes,
      mimeType: mimeType,
    );

    await _db
        .into(_db.entryPhotos)
        .insert(
          EntryPhotosCompanion.insert(
            id: photo.id,
            ownerId: ownerId,
            bytes: bytes,
            mimeType: mimeType,
            updatedAt: _now(),
          ),
        );

    return photo;
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.entryPhotos)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<void> deleteForOwner(String ownerId) async {
    await (_db.delete(
      _db.entryPhotos,
    )..where((p) => p.ownerId.equals(ownerId))).go();
  }
}
