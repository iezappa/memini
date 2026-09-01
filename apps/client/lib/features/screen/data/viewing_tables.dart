import 'package:drift/drift.dart';

import '../../../core/tracking/data/trackable_table.dart';
import '../domain/viewing.dart';

@DataClassName('ViewingRow')
class Viewings extends Table with TrackableTable {
  /// Stored by index rather than name: the set is closed and owned by this
  /// app, so a rename never has to touch stored rows.
  IntColumn get kind => intEnum<ViewingKind>()();

  IntColumn get releaseYear => integer().nullable()();
  TextColumn get director => text().nullable()();
  TextColumn get cast => text().nullable()();
  IntColumn get season => integer().nullable()();

  /// TMDB id, cached from an enrichment lookup.
  TextColumn get externalId => text().nullable()();
}
