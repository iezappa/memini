import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/concerts/data/gig_tables.dart';
import '../../features/dining/data/meal_tables.dart';
import '../../features/franchises/data/franchise_tables.dart';
import '../../features/games/data/game_tables.dart';
import '../../features/games/domain/game.dart';
import '../../features/rooms/data/room_tables.dart';
import '../../features/screen/data/viewing_tables.dart';
import '../../features/screen/domain/viewing.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Franchises, Rooms, Meals, Gigs, Viewings, Games])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'memini'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v2 opened the log to the other four domains. Every one of them is a
      // brand new table, so nothing existing has to be rewritten.
      if (from < 2) {
        await m.createTable(meals);
        await m.createTable(gigs);
        await m.createTable(viewings);
        await m.createTable(games);
      }
    },
    beforeOpen: (details) async {
      // SQLite disables foreign keys per connection, so every
      // onDelete action would silently do nothing without this.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
