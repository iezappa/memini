import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tracking/domain/tracking_filter.dart';
import '../domain/wish.dart';

class DriftWishRepository implements WishRepository {
  DriftWishRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Wish _toDomain(WishRow row) => Wish(
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
  );

  /// The watchlist's own query. It does not go through the shared tracking
  /// helpers because a wish has no rating and no day it happened — the two
  /// things those helpers are built around.
  SimpleSelectStatement<$WishesTable, WishRow> _query(WishFilter filter) {
    final query = _db.select(_db.wishes);

    final term = filter.searchTerm;
    if (term != null) {
      final pattern = '%${term.toLowerCase()}%';
      query.where(
        (w) =>
            w.title.lower().like(pattern) |
            w.description.lower().like(pattern) |
            // The note too: "the one the sister recommended" is exactly how
            // somebody looks for something on a list like this.
            w.note.lower().like(pattern),
      );
    }

    if (filter.kind != null) {
      query.where((w) => w.kind.equalsValue(filter.kind!));
    }

    // The four shared orderings collapse to three here, and the date they
    // order by is the day it was added: the only date a wish has.
    query.orderBy([
      switch (filter.sort) {
        TrackingSort.titleAsc => (w) => OrderingTerm.asc(w.title),
        TrackingSort.happenedOnAsc ||
        TrackingSort.ratingAsc => (w) => OrderingTerm.asc(w.addedOn),
        _ => (w) => OrderingTerm.desc(w.addedOn),
      },
    ]);

    return query;
  }

  @override
  Future<List<Wish>> list(WishFilter filter) async =>
      (await _query(filter).get()).map(_toDomain).toList();

  @override
  Stream<List<Wish>> watch(WishFilter filter) =>
      _query(filter).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Wish?> findById(String id) async {
    final row = await (_db.select(
      _db.wishes,
    )..where((w) => w.id.equals(id))).getSingleOrNull();

    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Wish> create(WishDraft draft) async {
    final row = await _db
        .into(_db.wishes)
        .insertReturning(
          WishesCompanion.insert(
            kind: draft.kind,
            title: draft.title.trim(),
            addedOn: dayOf(draft.addedOn),
            updatedAt: _now(),
            note: Value(draft.note),
            description: Value(draft.description),
            releaseYear: Value(draft.releaseYear),
            externalId: Value(draft.externalId),
            posterUrl: Value(draft.posterUrl),
          ),
        );

    return _toDomain(row);
  }

  @override
  Future<void> update(Wish wish) async {
    await (_db.update(_db.wishes)..where((w) => w.id.equals(wish.id))).write(
      WishesCompanion(
        kind: Value(wish.kind),
        title: Value(wish.title.trim()),
        note: Value(wish.note),
        description: Value(wish.description),
        releaseYear: Value(wish.releaseYear),
        externalId: Value(wish.externalId),
        posterUrl: Value(wish.posterUrl),
        updatedAt: Value(_now()),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.wishes)..where((w) => w.id.equals(id))).go();
  }
}
