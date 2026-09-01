import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tracking/data/tracking_query.dart';
import '../../../core/tracking/domain/tracking_filter.dart';
import '../domain/gig.dart';
import '../domain/gig_repository.dart';

class DriftGigRepository implements GigRepository {
  DriftGigRepository(this._db);

  final AppDatabase _db;

  TrackingColumns get _columns {
    final gigs = _db.gigs;
    return TrackingColumns(
      id: gigs.id,
      title: gigs.title,
      description: gigs.description,
      review: gigs.review,
      rating: gigs.rating,
      happenedOn: gigs.happenedOn,
    );
  }

  Gig _toDomain(GigRow row) => Gig(
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
  );

  SimpleSelectStatement<$GigsTable, GigRow> _query(GigFilter filter) {
    final query = _db.select(_db.gigs);

    final shared = trackingPredicate(_columns, filter);
    if (shared != null) query.where((_) => shared);

    final city = filter.city?.trim();
    if (city != null && city.isNotEmpty) {
      final pattern = '%${city.toLowerCase()}%';
      query.where((g) => g.city.lower().like(pattern));
    }

    final ordering = trackingOrdering(_columns, filter.sort);
    query.orderBy([for (final term in ordering) (_) => term]);

    return query;
  }

  @override
  Future<List<Gig>> list(GigFilter filter) async =>
      (await _query(filter).get()).map(_toDomain).toList();

  @override
  Stream<List<Gig>> watch(GigFilter filter) =>
      _query(filter).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Gig?> findById(int id) async {
    final row = await (_db.select(
      _db.gigs,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Gig> create(GigDraft draft) async {
    final row = await _db
        .into(_db.gigs)
        .insertReturning(
          GigsCompanion.insert(
            title: draft.title.trim(),
            happenedOn: dayOf(draft.happenedOn),
            photoPath: Value(draft.photoPath),
            description: Value(draft.description),
            rating: Value(draft.rating),
            review: Value(draft.review),
            venue: Value(draft.venue),
            city: Value(draft.city),
            supportActs: Value(draft.supportActs),
            setlist: Value(draft.setlist),
            company: Value(draft.company),
            externalId: Value(draft.externalId),
          ),
        );
    return _toDomain(row);
  }

  @override
  Future<void> update(Gig entry) async {
    await (_db.update(_db.gigs)..where((g) => g.id.equals(entry.id))).write(
      GigsCompanion(
        title: Value(entry.title.trim()),
        photoPath: Value(entry.photoPath),
        description: Value(entry.description),
        rating: Value(entry.rating),
        review: Value(entry.review),
        happenedOn: Value(dayOf(entry.happenedOn)),
        venue: Value(entry.venue),
        city: Value(entry.city),
        supportActs: Value(entry.supportActs),
        setlist: Value(entry.setlist),
        company: Value(entry.company),
        externalId: Value(entry.externalId),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.gigs)..where((g) => g.id.equals(id))).go();
  }
}
