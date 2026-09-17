import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/backup/data/backup_service.dart';
import 'package:memini/features/concerts/data/drift_gig_repository.dart';
import 'package:memini/features/concerts/domain/gig.dart';
import 'package:memini/features/concerts/domain/gig_repository.dart';
import 'package:memini/features/dining/data/drift_meal_repository.dart';
import 'package:memini/features/dining/domain/meal.dart';
import 'package:memini/features/dining/domain/meal_repository.dart';
import 'package:memini/features/games/data/drift_game_repository.dart';
import 'package:memini/features/games/domain/game.dart';
import 'package:memini/features/games/domain/game_repository.dart';
import 'package:memini/features/screen/data/drift_viewing_repository.dart';
import 'package:memini/features/screen/domain/viewing.dart';
import 'package:memini/features/screen/domain/viewing_repository.dart';
import 'package:memini/features/backup/domain/backup_document.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/rooms/domain/room_repository.dart';

void main() {
  late AppDatabase db;
  late BackupService service;
  late DriftRoomRepository rooms;
  late DriftFranchiseRepository franchises;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = BackupService(db);
    rooms = DriftRoomRepository(db);
    franchises = DriftFranchiseRepository(db);
  });

  tearDown(() => db.close());

  Future<void> seed() async {
    final franchise = await franchises.create(
      const FranchiseDraft(name: 'Enigma'),
    );
    await rooms.create(
      RoomDraft(
        title: 'The Vault',
        franchiseId: franchise.id,
        rating: 9.5,
        happenedOn: DateTime(2026, 3, 14),
        escaped: true,
        timeLeftMinutes: 4,
      ),
    );
  }

  test('exports the whole database and imports it back unchanged', () async {
    await seed();
    final json = await service.exportJson();

    await service.eraseEverything();
    expect(await rooms.list(const RoomFilter()), isEmpty);

    await service.import(json);

    final restored = await rooms.list(const RoomFilter());
    expect(restored.single.title, 'The Vault');
    expect(restored.single.rating, 9.5);
    expect(restored.single.franchiseId, isNotNull);
  });

  test('import replaces existing data instead of merging it', () async {
    await seed();
    final json = await service.exportJson();

    await rooms.create(
      RoomDraft(
        title: 'Added later',
        happenedOn: DateTime(2026, 6, 1),
        escaped: false,
      ),
    );
    expect(await rooms.list(const RoomFilter()), hasLength(2));

    await service.import(json);

    final restored = await rooms.list(const RoomFilter());
    expect(restored, hasLength(1));
    expect(restored.single.title, 'The Vault');
  });

  test('leaves the database untouched when the file is not JSON', () async {
    await seed();

    await expectLater(
      service.import('this is not json'),
      throwsA(isA<BackupFormatException>()),
    );

    expect(await rooms.list(const RoomFilter()), hasLength(1));
  });

  test('leaves the database untouched when the document is invalid', () async {
    await seed();

    await expectLater(
      service.import(
        '{"version": 1, "exportedAt": "2026-01-01T00:00:00.000",'
        ' "franchises": [], "rooms": [{"id": 1, "name": "Orphan",'
        ' "playedOn": "2026-01-01", "escaped": true, "franchiseId": 99}]}',
      ),
      throwsA(isA<BackupFormatException>()),
    );

    final survivors = await rooms.list(const RoomFilter());
    expect(survivors.single.title, 'The Vault');
  });

  test(
    'an older backup that still names photos imports without them',
    () async {
      // What builds with photos wrote: every entry carried a photoPath.
      const legacy =
          '{"version": 2, "exportedAt": "2026-01-01T00:00:00.000",'
          ' "franchises": [], "rooms": [{"id": 1, "title": "The Vault",'
          ' "photoPath": "/data/room_photos/1.jpg", "happenedOn":'
          ' "2026-03-14T00:00:00.000", "escaped": true}]}';

      final document = await service.import(legacy);

      expect(document.rooms, hasLength(1));
      final restored = await rooms.list(const RoomFilter());
      expect(restored.single.title, 'The Vault');
    },
  );

  test('an export no longer mentions photos', () async {
    await seed();

    expect(await service.exportJson(), isNot(contains('photoPath')));
  });

  test('exports CSV with one line per room', () async {
    await seed();

    final rooms = (await service.exportCsv())['rooms']!;

    expect(rooms.trim().split('\n'), hasLength(2));
    expect(rooms, contains('The Vault'));
  });

  group('every domain survives a round trip', () {
    /// One entry in each of the five domains, so a restore that silently
    /// drops a table fails loudly here instead of in the owner's data.
    Future<void> seedAllDomains() async {
      await DriftMealRepository(db).create(
        MealDraft(
          title: 'Don Julio',
          happenedOn: DateTime(2026, 3, 1),
          dish: 'Bife de chorizo',
          price: 42000,
          location: 'Palermo',
          rating: 9.5,
        ),
      );
      await DriftGigRepository(db).create(
        GigDraft(
          title: 'Radiohead',
          happenedOn: DateTime(2026, 3, 2),
          venue: 'Vélez',
          city: 'Buenos Aires',
          setlist: 'Bloom\nDaydreaming',
        ),
      );
      await DriftViewingRepository(db).create(
        ViewingDraft(
          title: 'Severance',
          kind: ViewingKind.series,
          season: 2,
          happenedOn: DateTime(2026, 3, 3),
          director: 'Ben Stiller',
        ),
      );
      await DriftGameRepository(db).create(
        GameDraft(
          title: 'Outer Wilds',
          status: GameStatus.hundredPercent,
          hoursPlayed: 27.5,
          platform: 'PC',
          happenedOn: DateTime(2026, 3, 4),
        ),
      );
    }

    test('export carries every domain, not just rooms', () async {
      await seed();
      await seedAllDomains();

      final document = await service.read();

      expect(document.rooms, hasLength(1));
      expect(document.meals, hasLength(1));
      expect(document.gigs, hasLength(1));
      expect(document.viewings, hasLength(1));
      expect(document.games, hasLength(1));
      expect(document.entryCount, 5);
    });

    test('import restores every domain with its own fields intact', () async {
      await seed();
      await seedAllDomains();
      final json = await service.exportJson();

      // Wipe everything, then restore from the file alone.
      await service.import(
        '{"version": 2, "exportedAt": "2026-01-01T00:00:00.000"}',
      );
      expect((await service.read()).entryCount, 0);

      await service.import(json);

      final meal = (await DriftMealRepository(db).list(const MealFilter()))
          .single;
      expect(meal.title, 'Don Julio');
      expect(meal.dish, 'Bife de chorizo');
      expect(meal.price, 42000);
      expect(meal.location, 'Palermo');
      expect(meal.rating, 9.5);

      final gig = (await DriftGigRepository(db).list(const GigFilter())).single;
      expect(gig.venue, 'Vélez');
      expect(gig.setlist, 'Bloom\nDaydreaming');

      final viewing = (await DriftViewingRepository(
        db,
      ).list(const ViewingFilter())).single;
      expect(viewing.kind, ViewingKind.series);
      expect(viewing.season, 2);
      expect(viewing.director, 'Ben Stiller');

      final game = (await DriftGameRepository(db).list(const GameFilter()))
          .single;
      expect(game.status, GameStatus.hundredPercent);
      expect(game.hoursPlayed, 27.5);
      expect(game.platform, 'PC');
    });

    test(
      'a version 1 file still restores, with the new domains empty',
      () async {
        await seedAllDomains();

        // What the first builds wrote: rooms and franchises only, int ids.
        const legacy =
            '{"version": 1, "exportedAt": "2026-01-01T00:00:00.000Z",'
            ' "franchises": [{"id": 4, "name": "Enigma"}],'
            ' "rooms": [{"id": 4, "title": "The Vault", "happenedOn":'
            ' "2026-03-14", "escaped": true, "franchiseId": 4}]}';

        final document = await service.import(legacy);

        expect(document.version, 1);
        expect(document.rooms, hasLength(1));
        expect(await DriftMealRepository(db).list(const MealFilter()), isEmpty);
        final room = (await rooms.list(const RoomFilter())).single;
        final franchise = (await franchises.listAll()).single;
        expect(room.franchiseId, franchise.id);
      },
    );

    test('csv exports one sheet per domain', () async {
      await seed();
      await seedAllDomains();

      final sheets = await service.exportCsv();

      expect(
        sheets.keys,
        containsAll(['rooms', 'meals', 'gigs', 'viewings', 'games']),
      );
      expect(sheets['meals'], contains('Bife de chorizo'));
      expect(sheets['games'], contains('hundredPercent'));
      // A multi-line setlist must stay inside one quoted cell.
      expect(sheets['gigs'], contains('"Bloom\nDaydreaming"'));
    });
  });

  group('relation integrity across a restore', () {
    test('a v3 round trip keeps ids, links and updatedAt exactly', () async {
      await seed();
      final before = (await rooms.list(const RoomFilter())).single;
      final franchise = (await franchises.listAll()).single;

      final json = await service.exportJson();
      await service.eraseEverything();
      await service.import(json);

      final after = (await rooms.list(const RoomFilter())).single;
      expect(after.id, before.id);
      expect(after.updatedAt, before.updatedAt);
      expect(after.franchiseId, franchise.id);
      expect(await franchises.findById(franchise.id), franchise);
    });

    test('a v2 file lands with every room on its own franchise', () async {
      const legacy =
          '{"version": 2, "exportedAt": "2026-08-01T10:00:00.000Z",'
          ' "franchises": [{"id": 1, "name": "Enigma"},'
          ' {"id": 2, "name": "Mystery"}],'
          ' "rooms": ['
          '{"id": 1, "title": "A", "happenedOn": "2026-03-14",'
          ' "escaped": true, "franchiseId": 2, "photoPath": "/p.jpg"},'
          '{"id": 2, "title": "B", "happenedOn": "2026-03-15",'
          ' "escaped": true, "franchiseId": 1}]}';

      await service.import(legacy);

      final byName = {for (final f in await franchises.listAll()) f.name: f.id};
      final byTitle = {
        for (final r in await rooms.list(const RoomFilter())) r.title: r,
      };
      expect(byTitle['A']!.franchiseId, byName['Mystery']);
      expect(byTitle['B']!.franchiseId, byName['Enigma']);

      // The links are real foreign keys, not just matching strings.
      await franchises.delete(byName['Mystery']!);
      expect((await rooms.findById(byTitle['A']!.id))!.franchiseId, isNull);
      expect(
        (await rooms.findById(byTitle['B']!.id))!.franchiseId,
        byName['Enigma'],
      );
    });
  });
}
