import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/franchise.dart';
import '../domain/franchise_repository.dart';

class DriftFranchiseRepository implements FranchiseRepository {
  DriftFranchiseRepository(this._db);

  final AppDatabase _db;

  Franchise _toDomain(FranchiseRow row) =>
      Franchise(id: row.id, name: row.name, logoPath: row.logoPath);

  SimpleSelectStatement<$FranchisesTable, FranchiseRow> get _ordered =>
      _db.select(_db.franchises)
        ..orderBy([(f) => OrderingTerm(expression: f.name)]);

  @override
  Future<List<Franchise>> listAll() async {
    final rows = await _ordered.get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<Franchise>> watchAll() =>
      _ordered.watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Franchise?> findById(int id) async {
    final row = await (_db.select(
      _db.franchises,
    )..where((f) => f.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Franchise> ensureByName(String name) async {
    final trimmed = name.trim();
    final existing =
        await (_db.select(_db.franchises)
              ..where((f) => f.name.lower().equals(trimmed.toLowerCase()))
              ..limit(1))
            .getSingleOrNull();

    if (existing != null) return _toDomain(existing);
    return create(FranchiseDraft(name: trimmed));
  }

  @override
  Future<Franchise> create(FranchiseDraft draft) async {
    final row = await _db
        .into(_db.franchises)
        .insertReturning(
          FranchisesCompanion.insert(
            name: draft.name.trim(),
            logoPath: Value(draft.logoPath),
          ),
        );
    return _toDomain(row);
  }

  @override
  Future<void> update(Franchise franchise) async {
    await (_db.update(
      _db.franchises,
    )..where((f) => f.id.equals(franchise.id))).write(
      FranchisesCompanion(
        name: Value(franchise.name.trim()),
        logoPath: Value(franchise.logoPath),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.franchises)..where((f) => f.id.equals(id))).go();
  }
}
