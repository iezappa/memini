import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/ids/uuid.dart';
import 'package:memini/features/concerts/data/drift_gig_repository.dart';
import 'package:memini/features/concerts/domain/gig.dart';
import 'package:memini/features/dining/data/drift_meal_repository.dart';
import 'package:memini/features/dining/domain/meal.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/games/data/drift_game_repository.dart';
import 'package:memini/features/games/domain/game.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/screen/data/drift_viewing_repository.dart';
import 'package:memini/features/screen/domain/viewing.dart';

/// Every record is born with a UUID and an updatedAt, and every write moves
/// updatedAt forward (STACK-APPS-DINAMICAS.md 1.1): cheap today, and what a
/// sync would need to decide which copy of a record is newer.
void main() {
  late AppDatabase db;
  late DateTime now;
  DateTime clock() => now;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime(2026, 9, 17, 10);
  });
  tearDown(() => db.close());

  final day = DateTime(2026, 3, 14);

  test('franchises', () async {
    final repo = DriftFranchiseRepository(db, now: clock);
    final created = await repo.create(const FranchiseDraft(name: 'Enigma'));
    expect(created.id, matches(uuidV4Pattern));
    expect(created.updatedAt, DateTime(2026, 9, 17, 10));

    now = DateTime(2026, 9, 18, 9);
    await repo.update(created.copyWith(name: 'Enigma Rooms'));
    expect((await repo.findById(created.id))!.updatedAt, now);
  });

  test('rooms', () async {
    final repo = DriftRoomRepository(db, now: clock);
    final created = await repo.create(
      RoomDraft(title: 'The Vault', happenedOn: day, escaped: true),
    );
    expect(created.id, matches(uuidV4Pattern));
    expect(created.updatedAt, DateTime(2026, 9, 17, 10));

    now = DateTime(2026, 9, 18, 9);
    await repo.update(created.copyWith(title: 'The Vault II'));
    expect((await repo.findById(created.id))!.updatedAt, now);
  });

  test('meals', () async {
    final repo = DriftMealRepository(db, now: clock);
    final created = await repo.create(
      MealDraft(title: 'Don Julio', happenedOn: day),
    );
    expect(created.id, matches(uuidV4Pattern));
    expect(created.updatedAt, DateTime(2026, 9, 17, 10));

    now = DateTime(2026, 9, 18, 9);
    await repo.update(created.copyWith(title: 'Don Julio!'));
    expect((await repo.findById(created.id))!.updatedAt, now);
  });

  test('gigs', () async {
    final repo = DriftGigRepository(db, now: clock);
    final created = await repo.create(
      GigDraft(title: 'Radiohead', happenedOn: day),
    );
    expect(created.id, matches(uuidV4Pattern));
    expect(created.updatedAt, DateTime(2026, 9, 17, 10));

    now = DateTime(2026, 9, 18, 9);
    await repo.update(created.copyWith(title: 'Radiohead live'));
    expect((await repo.findById(created.id))!.updatedAt, now);
  });

  test('viewings', () async {
    final repo = DriftViewingRepository(db, now: clock);
    final created = await repo.create(
      ViewingDraft(
        title: 'Severance',
        happenedOn: day,
        kind: ViewingKind.series,
      ),
    );
    expect(created.id, matches(uuidV4Pattern));
    expect(created.updatedAt, DateTime(2026, 9, 17, 10));

    now = DateTime(2026, 9, 18, 9);
    await repo.update(created.copyWith(title: 'Severance S2'));
    expect((await repo.findById(created.id))!.updatedAt, now);
  });

  test('games', () async {
    final repo = DriftGameRepository(db, now: clock);
    final created = await repo.create(
      GameDraft(
        title: 'Outer Wilds',
        happenedOn: day,
        status: GameStatus.values.first,
      ),
    );
    expect(created.id, matches(uuidV4Pattern));
    expect(created.updatedAt, DateTime(2026, 9, 17, 10));

    now = DateTime(2026, 9, 18, 9);
    await repo.update(created.copyWith(title: 'Outer Wilds DLC'));
    expect((await repo.findById(created.id))!.updatedAt, now);
  });

  test(
    'two records created in the same instant still get distinct ids',
    () async {
      final repo = DriftRoomRepository(db, now: clock);
      final a = await repo.create(
        RoomDraft(title: 'A', happenedOn: day, escaped: true),
      );
      final b = await repo.create(
        RoomDraft(title: 'B', happenedOn: day, escaped: true),
      );
      expect(a.id, isNot(b.id));
    },
  );
}
