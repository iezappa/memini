import 'package:drift/drift.dart';

import '../../../core/tracking/data/trackable_table.dart';
import '../domain/game.dart';

@DataClassName('GameRow')
class Games extends Table with TrackableTable {
  IntColumn get status => intEnum<GameStatus>()();
  TextColumn get platform => text().nullable()();
  RealColumn get hoursPlayed => real().nullable()();
  IntColumn get releaseYear => integer().nullable()();

  /// RAWG or IGDB id, cached from an enrichment lookup.
  TextColumn get externalId => text().nullable()();
}
