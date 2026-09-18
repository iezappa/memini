// dart format width=80
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/ids/uuid.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

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

  // No commit of this repository ever had schemaVersion 1: the first commit
  // already shipped v2. The v1 dump is reconstructed from the v1 -> v2
  // migration itself, which only creates the four newer tables and leaves
  // franchises and rooms alone, so v1 is exactly those two v2 tables.
  test(
    'v1 to v3 keeps franchises and rooms, and adds the other domains',
    () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 3,
        createOld: v1.DatabaseAtV1.new,
        createNew: v3.DatabaseAtV3.new,
        openTestedDatabase: AppDatabase.forTesting,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.franchises, [
            const v1.FranchisesData(id: 1, name: 'Enigma'),
          ]);
          batch.insertAll(oldDb.rooms, [
            const v1.RoomsData(
              id: 1,
              title: 'The Vault',
              photoPath: '/data/room_photos/1.jpg',
              review: 'Tight',
              rating: 9.5,
              happenedOn: 1773446400,
              franchiseId: 1,
              escaped: 1,
              timeLeftMinutes: 4,
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
              review: 'Tight',
              rating: 9.5,
              happenedOn: 1773446400,
              franchiseId: 1,
              escaped: 1,
              timeLeftMinutes: 4,
            ),
          ]);
          expect(await newDb.select(newDb.meals).get(), isEmpty);
          expect(await newDb.select(newDb.games).get(), isEmpty);
        },
      );
    },
  );

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

  group('v4 gives every record a UUID and an updatedAt', () {
    // Seconds since the epoch, the way Drift stores a DateTime.
    int epoch(DateTime value) => value.millisecondsSinceEpoch ~/ 1000;

    test('from v3, keeping every room linked to its own franchise', () async {
      final before = epoch(DateTime.now());
      await verifier.testWithDataIntegrity(
        oldVersion: 3,
        newVersion: 4,
        createOld: v3.DatabaseAtV3.new,
        createNew: v4.DatabaseAtV4.new,
        openTestedDatabase: AppDatabase.forTesting,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.franchises, [
            const v3.FranchisesData(id: 1, name: 'Enigma'),
            const v3.FranchisesData(id: 2, name: 'Mystery', logoPath: '/l.png'),
          ]);
          batch.insertAll(oldDb.rooms, [
            // Inserted out of id order on purpose: the franchise link must
            // follow the id, not the position.
            const v3.RoomsData(
              id: 5,
              title: 'The Lab',
              happenedOn: 1773532800,
              franchiseId: 2,
              escaped: 0,
            ),
            const v3.RoomsData(
              id: 1,
              title: 'The Vault',
              description: 'A heist',
              review: 'Tight',
              rating: 9.5,
              happenedOn: 1773446400,
              franchiseId: 1,
              escaped: 1,
              timeLeftMinutes: 4,
            ),
            const v3.RoomsData(
              id: 2,
              title: 'The Tomb',
              happenedOn: 1773446400,
              franchiseId: 1,
              escaped: 1,
            ),
            const v3.RoomsData(
              id: 3,
              title: 'Loose',
              happenedOn: 1773446400,
              escaped: 1,
            ),
          ]);
          batch.insertAll(oldDb.meals, [
            const v3.MealsData(
              id: 1,
              title: 'Don Julio',
              happenedOn: 1773532800,
              dish: 'Bife de chorizo',
              price: 42.5,
            ),
          ]);
          batch.insertAll(oldDb.gigs, [
            const v3.GigsData(
              id: 1,
              title: 'Radiohead',
              happenedOn: 1773619200,
              externalId: 'mbid',
            ),
          ]);
          batch.insertAll(oldDb.viewings, [
            const v3.ViewingsData(
              id: 1,
              title: 'Severance',
              happenedOn: 1773705600,
              kind: 1,
              season: 2,
            ),
          ]);
          batch.insertAll(oldDb.games, [
            const v3.GamesData(
              id: 1,
              title: 'Outer Wilds',
              happenedOn: 1773792000,
              status: 2,
              hoursPlayed: 21,
            ),
          ]);
        },
        validateItems: (newDb) async {
          final after = epoch(DateTime.now()) + 1;
          final franchises = await newDb.select(newDb.franchises).get();
          final byName = {for (final f in franchises) f.name: f};
          expect(byName.keys, unorderedEquals(['Enigma', 'Mystery']));
          expect(byName['Mystery']!.logoPath, '/l.png');

          final rooms = await newDb.select(newDb.rooms).get();
          expect(rooms.map((r) => r.title), [
            'The Vault',
            'The Tomb',
            'Loose',
            'The Lab',
          ], reason: 'rows are copied in old id order, the tie-break before');
          final room = {for (final r in rooms) r.title: r};
          expect(room['The Vault']!.franchiseId, byName['Enigma']!.id);
          expect(room['The Tomb']!.franchiseId, byName['Enigma']!.id);
          expect(room['The Lab']!.franchiseId, byName['Mystery']!.id);
          expect(room['Loose']!.franchiseId, isNull);
          expect(room['The Vault']!.review, 'Tight');
          expect(room['The Vault']!.rating, 9.5);
          expect(room['The Vault']!.timeLeftMinutes, 4);

          final meal = (await newDb.select(newDb.meals).get()).single;
          expect(meal.dish, 'Bife de chorizo');
          expect(meal.price, 42.5);
          expect(
            (await newDb.select(newDb.gigs).get()).single.externalId,
            'mbid',
          );
          expect((await newDb.select(newDb.viewings).get()).single.season, 2);
          expect(
            (await newDb.select(newDb.games).get()).single.hoursPlayed,
            21,
          );

          final ids = <String>[];
          final stamps = <int>[];
          for (final f in franchises) {
            ids.add(f.id);
            stamps.add(f.updatedAt);
          }
          for (final r in rooms) {
            ids.add(r.id);
            stamps.add(r.updatedAt);
          }
          for (final row in [...await newDb.select(newDb.meals).get()]) {
            ids.add(row.id);
            stamps.add(row.updatedAt);
          }
          for (final id in ids) {
            expect(id, matches(uuidV4Pattern));
          }
          expect(ids.toSet(), hasLength(ids.length));
          for (final stamp in stamps) {
            expect(stamp, inInclusiveRange(before, after));
          }
        },
      );
    });

    test('from v2, photo paths dropped and links kept on the way', () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 2,
        newVersion: 4,
        createOld: v2.DatabaseAtV2.new,
        createNew: v4.DatabaseAtV4.new,
        openTestedDatabase: AppDatabase.forTesting,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.franchises, [
            const v2.FranchisesData(id: 7, name: 'Enigma'),
          ]);
          batch.insertAll(oldDb.rooms, [
            const v2.RoomsData(
              id: 1,
              title: 'The Vault',
              photoPath: '/p.jpg',
              happenedOn: 1773446400,
              franchiseId: 7,
              escaped: 1,
            ),
          ]);
        },
        validateItems: (newDb) async {
          final franchise = (await newDb.select(newDb.franchises).get()).single;
          final room = (await newDb.select(newDb.rooms).get()).single;
          expect(room.franchiseId, franchise.id);
          expect(room.id, matches(uuidV4Pattern));
        },
      );
    });

    test('from v1, links kept on the way', () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 4,
        createOld: v1.DatabaseAtV1.new,
        createNew: v4.DatabaseAtV4.new,
        openTestedDatabase: AppDatabase.forTesting,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.franchises, [
            const v1.FranchisesData(id: 3, name: 'Enigma'),
          ]);
          batch.insertAll(oldDb.rooms, [
            const v1.RoomsData(
              id: 9,
              title: 'The Vault',
              happenedOn: 1773446400,
              franchiseId: 3,
              escaped: 1,
            ),
          ]);
        },
        validateItems: (newDb) async {
          final franchise = (await newDb.select(newDb.franchises).get()).single;
          final room = (await newDb.select(newDb.rooms).get()).single;
          expect(room.franchiseId, franchise.id);
        },
      );
    });

    test('a room pointing at a franchise that is gone is detached', () async {
      final schema = await verifier.schemaAt(3);
      final old = v3.DatabaseAtV3(schema.newConnection());
      // Foreign keys are off on a fresh connection, which is how a store can
      // hold this row in the first place — an older build wrote it before the
      // pragma was set on every connection.
      await old
          .into(old.rooms)
          .insert(
            const v3.RoomsData(
              id: 1,
              title: 'The Vault',
              happenedOn: 1773446400,
              franchiseId: 404,
              escaped: 1,
            ),
          );
      await old.close();

      final db = AppDatabase.forTesting(schema.newConnection());
      final room = await db.select(db.rooms).getSingle();
      expect(
        room.franchiseId,
        isNull,
        reason: 'the upgrade heals the reference instead of refusing to open',
      );
      expect(room.title, 'The Vault');
      expect(await db.select(db.franchises).get(), isEmpty);
      await db.close();
    });

    test(
      'a franchise deleted after the upgrade still detaches its rooms',
      () async {
        final schema = await verifier.schemaAt(3);
        final old = v3.DatabaseAtV3(schema.newConnection());
        await old
            .into(old.franchises)
            .insert(const v3.FranchisesData(id: 1, name: 'Enigma'));
        await old
            .into(old.rooms)
            .insert(
              const v3.RoomsData(
                id: 1,
                title: 'The Vault',
                happenedOn: 1773446400,
                franchiseId: 1,
                escaped: 1,
              ),
            );
        await old.close();

        final db = AppDatabase.forTesting(schema.newConnection());
        final franchise = await db.select(db.franchises).getSingle();
        await (db.delete(
          db.franchises,
        )..where((f) => f.id.equals(franchise.id))).go();
        expect((await db.select(db.rooms).getSingle()).franchiseId, isNull);
        await db.close();
      },
    );
  });

  group('an upgrade interrupted halfway', () {
    // A crash partway through an upgrade is the ordinary case on a phone.
    // Drift records user_version after each step, so the store reopens at the
    // last version that finished — but only if the step that died left the
    // schema exactly as it found it. A step that rebuilds five tables one
    // after another does not, unless the whole run is one transaction.
    test('rolls the whole step back and leaves the store openable', () async {
      final schema = await verifier.schemaAt(2);

      final old = v2.DatabaseAtV2(schema.newConnection());
      await old
          .into(old.franchises)
          .insert(const v2.FranchisesData(id: 1, name: 'Enigma'));
      await old
          .into(old.rooms)
          .insert(
            const v2.RoomsData(
              id: 1,
              title: 'The Vault',
              photoPath: '/p.jpg',
              happenedOn: 1773446400,
              franchiseId: 1,
              escaped: 1,
            ),
          );
      // An index over the column v3 removes. Drift re-creates the indexes of
      // a table it rebuilds, and this one no longer resolves afterwards, so
      // the third of the five rebuilds in the v2 -> v3 step throws — the two
      // before it having already run.
      await old.customStatement('CREATE INDEX gigs_photo ON gigs (photo_path)');
      await old.close();

      final interrupted = AppDatabase.forTesting(schema.newConnection());
      await expectLater(
        interrupted.customSelect('SELECT 1').get(),
        throwsA(anything),
      );
      await interrupted.close();

      final after = v2.DatabaseAtV2(schema.newConnection());
      final roomColumns =
          (await after.customSelect('PRAGMA table_info(rooms)').get()).map(
            (row) => row.read<String>('name'),
          );
      expect(
        roomColumns,
        contains('photo_path'),
        reason:
            'a step that died must leave the schema it found, or the '
            'store is half of one version and half of another',
      );
      expect((await after.select(after.rooms).getSingle()).photoPath, '/p.jpg');
      // Clearing the obstruction stands for the cause of the crash being
      // gone: the retry has to carry the data through.
      await after.customStatement('DROP INDEX gigs_photo');
      await after.close();

      final db = AppDatabase.forTesting(schema.newConnection());
      final franchise = await db.select(db.franchises).getSingle();
      final room = await db.select(db.rooms).getSingle();
      expect(room.title, 'The Vault');
      expect(room.franchiseId, franchise.id);
      await db.close();
    });
  });

  group('the photos left on disk', () {
    test('are cleaned up once when a v2 store is upgraded', () async {
      var cleanups = 0;
      final schema = await verifier.schemaAt(2);
      final db = AppDatabase.forTesting(
        schema.newConnection(),
        onPhotosDropped: () async => cleanups++,
      );

      await verifier.migrateAndValidate(db, 4);
      await db.close();

      expect(cleanups, 1);
    });

    test('are not looked for when the store is created fresh', () async {
      var cleanups = 0;
      final schema = await verifier.schemaAt(4);
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

      await verifier.migrateAndValidate(db, 4);
      await db.close();
    });
  });
}

class FileSystemLikeFailure implements Exception {
  const FileSystemLikeFailure();
}
