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
}
