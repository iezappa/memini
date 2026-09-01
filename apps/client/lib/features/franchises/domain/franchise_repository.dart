import 'franchise.dart';

/// Domain port for franchise persistence.
abstract interface class FranchiseRepository {
  Future<List<Franchise>> listAll();

  Future<Franchise?> findById(int id);

  /// Returns the franchise with this name, creating it if absent.
  /// Matching is case-insensitive and ignores surrounding whitespace.
  Future<Franchise> ensureByName(String name);

  Future<Franchise> create(FranchiseDraft draft);

  Future<void> update(Franchise franchise);

  /// Deletes the franchise. Rooms that referenced it keep existing with no
  /// franchise attached.
  Future<void> delete(int id);

  Stream<List<Franchise>> watchAll();
}
