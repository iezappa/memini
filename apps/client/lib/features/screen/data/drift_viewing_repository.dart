import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tracking/data/tracking_query.dart';
import '../../../core/tracking/domain/tracking_filter.dart';
import '../domain/viewing.dart';
import '../domain/viewing_repository.dart';

class DriftViewingRepository implements ViewingRepository {
  DriftViewingRepository(this._db);

  final AppDatabase _db;

  TrackingColumns get _columns {
    final viewings = _db.viewings;
    return TrackingColumns(
      id: viewings.id,
      title: viewings.title,
      description: viewings.description,
      review: viewings.review,
      rating: viewings.rating,
      happenedOn: viewings.happenedOn,
    );
  }

  Viewing _toDomain(ViewingRow row) => Viewing(
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
  );

  SimpleSelectStatement<$ViewingsTable, ViewingRow> _query(
    ViewingFilter filter,
  ) {
    final query = _db.select(_db.viewings);

    final shared = trackingPredicate(_columns, filter);
    if (shared != null) query.where((_) => shared);

    if (filter.kind != null) {
      query.where((v) => v.kind.equalsValue(filter.kind!));
    }

    final ordering = trackingOrdering(_columns, filter.sort);
    query.orderBy([for (final term in ordering) (_) => term]);

    return query;
  }

  @override
  Future<List<Viewing>> list(ViewingFilter filter) async =>
      (await _query(filter).get()).map(_toDomain).toList();

  @override
  Stream<List<Viewing>> watch(ViewingFilter filter) =>
      _query(filter).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Viewing?> findById(int id) async {
    final row = await (_db.select(
      _db.viewings,
    )..where((v) => v.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Viewing> create(ViewingDraft draft) async {
    final row = await _db
        .into(_db.viewings)
        .insertReturning(
          ViewingsCompanion.insert(
            title: draft.title.trim(),
            happenedOn: dayOf(draft.happenedOn),
            kind: draft.kind,
            photoPath: Value(draft.photoPath),
            description: Value(draft.description),
            rating: Value(draft.rating),
            review: Value(draft.review),
            releaseYear: Value(draft.releaseYear),
            director: Value(draft.director),
            cast: Value(draft.cast),
            season: Value(draft.season),
            externalId: Value(draft.externalId),
          ),
        );
    return _toDomain(row);
  }

  @override
  Future<void> update(Viewing entry) async {
    await (_db.update(_db.viewings)..where((v) => v.id.equals(entry.id))).write(
      ViewingsCompanion(
        title: Value(entry.title.trim()),
        photoPath: Value(entry.photoPath),
        description: Value(entry.description),
        rating: Value(entry.rating),
        review: Value(entry.review),
        happenedOn: Value(dayOf(entry.happenedOn)),
        kind: Value(entry.kind),
        releaseYear: Value(entry.releaseYear),
        director: Value(entry.director),
        cast: Value(entry.cast),
        season: Value(entry.season),
        externalId: Value(entry.externalId),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.viewings)..where((v) => v.id.equals(id))).go();
  }
}
