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
import '../ids/uuid.dart';
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
  static const currentSchemaVersion = 4;

  @override
  int get schemaVersion => currentSchemaVersion;

  /// A random version 4 UUID, evaluated per row, in plain SQLite: sixteen
  /// random bytes as lowercase hex, with the version and variant nibbles set.
  static const _uuidSql =
      "(lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' "
      "|| substr(lower(hex(randomblob(2))), 2) || '-' "
      "|| substr('89ab', 1 + (abs(random()) % 4), 1) "
      "|| substr(lower(hex(randomblob(2))), 2) || '-' "
      '|| lower(hex(randomblob(6))))';

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Foreign keys go off for the duration: rebuilding a table drops and
      // re-creates it, which would trip every reference into it. The pragma
      // is a no-op inside a transaction, so it has to be set out here —
      // beforeOpen turns them back on for the connection either way.
      await customStatement('PRAGMA foreign_keys = OFF');

      // The whole upgrade is one transaction. SQLite makes DDL transactional,
      // so a crash anywhere in here — between two steps, or between the DROP
      // and the RENAME of a single rebuilt table — rolls back to the schema
      // and the rows the store had before, and the next launch simply runs
      // the upgrade again. Without it the store can come back half of one
      // version and half of another, which is unopenable and unrepairable.
      // This is the shape drift documents for a custom onUpgrade.
      await transaction(() async {
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
            // A room whose franchise_id points at a franchise that is no
            // longer there comes out of this with a null link, because the
            // lookup into franchise_ids finds nothing. That heal is
            // deliberate: an upgrade is the one moment the user cannot do
            // anything about a corrupt store, so a detached room beats a
            // store that refuses to open. Importing a backup takes the
            // opposite view and rejects the file
            // (backup_document.dart, 'dangling-franchise-reference'): there
            // the user still has the original, and silently dropping a link
            // they can see in the file would be the surprise.
            //
            // v4 gives every record a UUID and an updatedAt (1.1 of the
            // standard). Every table is rebuilt; franchise ids are minted first,
            // into a temporary map, so each room's link is rewritten onto the
            // new id of the franchise it pointed at. Rows are copied in rowid
            // order, which the lists use to tie-break entries on the same day.
            from3To4: (m, schema) async {
              final stamp = Variable<DateTime>(DateTime.now());

              await customStatement(
                'CREATE TEMP TABLE franchise_ids AS '
                'SELECT id AS old_id, $_uuidSql AS new_id FROM franchises',
              );

              await m.alterTable(
                TableMigration(
                  schema.franchises,
                  columnTransformer: {
                    schema.franchises.id: const CustomExpression<String>(
                      '(SELECT new_id FROM franchise_ids '
                      'WHERE old_id = franchises.id)',
                    ),
                    schema.franchises.updatedAt: stamp,
                  },
                  newColumns: [schema.franchises.updatedAt],
                ),
              );

              await m.alterTable(
                TableMigration(
                  schema.rooms,
                  columnTransformer: {
                    schema.rooms.id: const CustomExpression<String>(_uuidSql),
                    schema.rooms.franchiseId: const CustomExpression<String>(
                      '(SELECT new_id FROM franchise_ids '
                      'WHERE old_id = rooms.franchise_id)',
                    ),
                    schema.rooms.updatedAt: stamp,
                  },
                  newColumns: [schema.rooms.updatedAt],
                ),
              );

              for (final (table, id, updatedAt) in [
                (schema.meals, schema.meals.id, schema.meals.updatedAt),
                (schema.gigs, schema.gigs.id, schema.gigs.updatedAt),
                (
                  schema.viewings,
                  schema.viewings.id,
                  schema.viewings.updatedAt,
                ),
                (schema.games, schema.games.id, schema.games.updatedAt),
              ]) {
                await m.alterTable(
                  TableMigration(
                    table,
                    columnTransformer: {
                      id: const CustomExpression<String>(_uuidSql),
                      updatedAt: stamp,
                    },
                    newColumns: [updatedAt],
                  ),
                );
              }

              await customStatement('DROP TABLE franchise_ids');
            },
          ),
        );
      });

      await customStatement('PRAGMA foreign_keys = ON');
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
