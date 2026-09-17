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
import 'app_database.steps.dart';
import 'legacy_photos.dart';
import 'storage_durability.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Franchises, Rooms, Meals, Gigs, Viewings, Games])
class AppDatabase extends _$AppDatabase {
  AppDatabase({void Function(StorageDurability)? onStorageChosen})
    : onPhotosDropped = deleteLegacyPhotos,
      super(
        driftDatabase(
          name: storeName,
          web: DriftWebOptions(
            sqlite3Wasm: sqlite3WasmUri,
            driftWorker: driftWorkerUri,
            onResult: (result) => onStorageChosen?.call(
              durabilityOf(result.chosenImplementation),
            ),
          ),
        ),
      );

  /// The name the store is opened under: `memini.sqlite` on native
  /// platforms, the browser database of the same name on the web.
  static const storeName = 'memini';

  /// Where the browser build finds its database engine, relative to the base
  /// href so the Pages build under /memini/ resolves them too. Both files
  /// live in web/ and are pinned to the lockfile's drift and sqlite3.
  static final sqlite3WasmUri = Uri.parse('sqlite3.wasm');
  static final driftWorkerUri = Uri.parse('drift_worker.js');

  AppDatabase.forTesting(super.executor, {this.onPhotosDropped});

  /// Runs once, after a store from before v3 has been upgraded, to remove the
  /// photo files its rows used to point at.
  final Future<void> Function()? onPhotosDropped;

  /// The schema this build writes, readable without opening a store — which
  /// is exactly when recovery needs it.
  static const currentSchemaVersion = 3;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      await m.runMigrationSteps(
        from: from,
        to: to,
        steps: migrationSteps(
          // v2 opened the log to the other four domains. Every one of them is
          // a brand new table, so nothing existing has to be rewritten.
          from1To2: (m, schema) async {
            await m.createTable(schema.meals);
            await m.createTable(schema.gigs);
            await m.createTable(schema.viewings);
            await m.createTable(schema.games);
          },
          // v3 removed photos: every tracked table loses its photo_path.
          // Each table is rebuilt from its v3 shape, which works on every
          // SQLite build, including those without ALTER TABLE DROP COLUMN.
          from2To3: (m, schema) async {
            await m.alterTable(TableMigration(schema.rooms));
            await m.alterTable(TableMigration(schema.meals));
            await m.alterTable(TableMigration(schema.gigs));
            await m.alterTable(TableMigration(schema.viewings));
            await m.alterTable(TableMigration(schema.games));
          },
        ),
      );
    },
    beforeOpen: (details) async {
      final before = details.versionBefore;
      if (before != null && before < 3) {
        try {
          await onPhotosDropped?.call();
        } catch (_) {
          // Leftover files only cost space; the upgrade itself is done.
        }
      }

      // SQLite disables foreign keys per connection, so every
      // onDelete action would silently do nothing without this.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
