import 'package:drift/drift.dart';

/// A picture the owner took, for an entry that no service has artwork for.
///
/// Memini kept photos once and dropped them in v3, because it kept a *path*
/// to a file it did not own: the picture vanished when the file moved, and
/// on the web there was no path to keep at all. This keeps the bytes, which
/// is the part that made the old design fail.
///
/// [ownerId] is the entry's id and carries no foreign key, because the five
/// domains are five tables and a photo belongs to whichever one it came
/// from. Each repository deletes its own photos when it deletes an entry.
///
/// Deliberately absent from the backup JSON: a file of a few kilobytes is
/// something you can mail yourself, and one with photographs in it is not.
/// They are copied into the backup folder as files instead — see
/// `PhotoFolder`.
@DataClassName('EntryPhotoRow')
// Written out in full, with `IF NOT EXISTS`, because creating the store
// has to survive being run twice: a browser that loses `user_version`
// leaves every table on disk and the next launch creates the schema
// again (see database_health_test). Tables already tolerate that;
// an index only does when it says so.
@TableIndex.sql(
  'CREATE INDEX IF NOT EXISTS photo_by_owner ON entry_photos (owner_id)',
)
class EntryPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();

  /// The picture itself.
  BlobColumn get bytes => blob()();

  /// What kind of picture it is, so it can be written back out with the
  /// right extension and shown without guessing.
  TextColumn get mimeType => text().withLength(max: 60)();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
