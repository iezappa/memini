import '../../database/app_database.dart';

/// Photos belong to whichever of the five tables their entry came from, so
/// they carry an owner id and no foreign key — and with no foreign key
/// there is no ON DELETE CASCADE to do this for us.
///
/// Every repository that deletes an entry calls this in the same
/// transaction, because a picture whose entry is gone is unreachable: no
/// screen can show it and nothing can delete it, and it keeps its bytes in
/// the store for good.
extension EntryPhotoCascade on AppDatabase {
  Future<void> deletePhotosOf(String ownerId) =>
      (delete(entryPhotos)..where((p) => p.ownerId.equals(ownerId))).go();
}
