import 'package:drift/drift.dart';

import '../../../core/tracking/data/trackable_table.dart';

@DataClassName('GigRow')
class Gigs extends Table with TrackableTable {
  TextColumn get venue => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get supportActs => text().nullable()();
  TextColumn get setlist => text().nullable()();
  TextColumn get company => text().nullable()();

  /// MusicBrainz artist id, cached from an enrichment lookup.
  TextColumn get externalId => text().nullable()();

  /// Where the photographs of the night live: a shared album, wherever the
  /// owner keeps it. A link and not the pictures — an album of a concert is
  /// two hundred photographs, and the ones worth keeping in the app can be
  /// attached to the entry like any other.
  TextColumn get photosUrl => text().nullable()();

  /// A video of the night. Someone else's recording as often as the owner's,
  /// which is why it is a link and not a file.
  TextColumn get videoUrl => text().nullable()();
}
