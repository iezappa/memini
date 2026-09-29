import 'package:drift/drift.dart';

import '../../../core/tracking/data/trackable_table.dart';

@DataClassName('BookRow')
class Books extends Table with TrackableTable {
  /// The author string Open Library returns, or what the owner typed.
  TextColumn get author => text().nullable()();

  IntColumn get publicationYear => integer().nullable()();

  /// Open Library work key, cached when the owner enriched the entry.
  TextColumn get externalId => text().nullable()();

  /// The cover URL, usually served by Open Library's cover endpoint.
  TextColumn get coverUrl => text().nullable()();
}
