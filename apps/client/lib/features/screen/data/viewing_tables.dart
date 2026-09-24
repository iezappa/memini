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

  /// The cover and the wide still, as whole URLs on TMDB's image host.
  ///
  /// The address, not the picture: this app copies nobody's artwork onto the
  /// device. It is a link that loads when a card or a page is on screen and
  /// leaves nothing behind, which is the same bargain the lookup itself
  /// makes — and it is why removing an entry needs no cleanup, unlike the
  /// photos this app used to keep and dropped in v3.
  TextColumn get posterUrl => text().nullable()();
  TextColumn get backdropUrl => text().nullable()();
}
