// dart format width=80
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('every schema upgrade matches the dumped schema', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase.forTesting(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v2 to v3 drops the photo paths and keeps everything else', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.forTesting,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.franchises, [
          const v2.FranchisesData(id: 1, name: 'Enigma'),
        ]);
        batch.insertAll(oldDb.rooms, [
          const v2.RoomsData(
            id: 1,
            title: 'The Vault',
            photoPath: '/data/room_photos/1.jpg',
            rating: 9.5,
            happenedOn: 1773446400,
            franchiseId: 1,
            escaped: 1,
            timeLeftMinutes: 4,
          ),
        ]);
        batch.insertAll(oldDb.meals, [
          const v2.MealsData(
            id: 1,
            title: 'Don Julio',
            photoPath: '/data/room_photos/2.jpg',
            happenedOn: 1773532800,
            dish: 'Bife de chorizo',
          ),
        ]);
        batch.insertAll(oldDb.gigs, [
          const v2.GigsData(
            id: 1,
            title: 'Radiohead',
            photoPath: '/p.jpg',
            happenedOn: 1773619200,
          ),
        ]);
        batch.insertAll(oldDb.viewings, [
          const v2.ViewingsData(
            id: 1,
            title: 'Severance',
            photoPath: '/poster.jpg',
            happenedOn: 1773705600,
            kind: 1,
          ),
        ]);
        batch.insertAll(oldDb.games, [
          const v2.GamesData(
            id: 1,
            title: 'Outer Wilds',
            photoPath: '/cover.jpg',
            happenedOn: 1773792000,
            status: 2,
          ),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.franchises).get(), [
          const v3.FranchisesData(id: 1, name: 'Enigma'),
        ]);
        expect(await newDb.select(newDb.rooms).get(), [
          const v3.RoomsData(
            id: 1,
            title: 'The Vault',
            rating: 9.5,
            happenedOn: 1773446400,
            franchiseId: 1,
            escaped: 1,
            timeLeftMinutes: 4,
          ),
        ]);
        expect(await newDb.select(newDb.meals).get(), [
          const v3.MealsData(
            id: 1,
            title: 'Don Julio',
            happenedOn: 1773532800,
            dish: 'Bife de chorizo',
          ),
        ]);
        expect(await newDb.select(newDb.gigs).get(), [
          const v3.GigsData(id: 1, title: 'Radiohead', happenedOn: 1773619200),
        ]);
        expect(await newDb.select(newDb.viewings).get(), [
          const v3.ViewingsData(
            id: 1,
            title: 'Severance',
            happenedOn: 1773705600,
            kind: 1,
          ),
        ]);
        expect(await newDb.select(newDb.games).get(), [
          const v3.GamesData(
            id: 1,
            title: 'Outer Wilds',
            happenedOn: 1773792000,
            status: 2,
          ),
        ]);
      },
    );
  });

  group('the photos left on disk', () {
    test('are cleaned up once when a v2 store is upgraded', () async {
      var cleanups = 0;
      final schema = await verifier.schemaAt(2);
      final db = AppDatabase.forTesting(
        schema.newConnection(),
        onPhotosDropped: () async => cleanups++,
      );

      await verifier.migrateAndValidate(db, 3);
      await db.close();

      expect(cleanups, 1);
    });

    test('are not looked for when the store is created fresh', () async {
      var cleanups = 0;
      final schema = await verifier.schemaAt(3);
      final db = AppDatabase.forTesting(
        schema.newConnection(),
        onPhotosDropped: () async => cleanups++,
      );

      await db.customSelect('SELECT 1').get();
      await db.close();

      expect(cleanups, 0);
    });

    test('a failing clean-up never breaks the upgrade', () async {
      final schema = await verifier.schemaAt(2);
      final db = AppDatabase.forTesting(
        schema.newConnection(),
        onPhotosDropped: () async => throw const FileSystemLikeFailure(),
      );

      await verifier.migrateAndValidate(db, 3);
      await db.close();
    });
  });
}

class FileSystemLikeFailure implements Exception {
  const FileSystemLikeFailure();
}
