import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';

void main() {
  late AppDatabase db;
  late DriftFranchiseRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftFranchiseRepository(db);
  });

  tearDown(() => db.close());

  test('creates a franchise and reads it back', () async {
    final created = await repository.create(
      const FranchiseDraft(name: 'Enigma', logoPath: '/tmp/logo.png'),
    );

    expect(created.name, 'Enigma');
    expect(await repository.findById(created.id), created);
  });

  test('trims the name on create', () async {
    final created = await repository.create(
      const FranchiseDraft(name: '  Enigma  '),
    );

    expect(created.name, 'Enigma');
  });

  test('lists franchises alphabetically', () async {
    await repository.create(const FranchiseDraft(name: 'Zen'));
    await repository.create(const FranchiseDraft(name: 'Alfa'));

    final names = (await repository.listAll()).map((f) => f.name).toList();

    expect(names, ['Alfa', 'Zen']);
  });

  group('ensureByName', () {
    test('creates the franchise when it does not exist', () async {
      final created = await repository.ensureByName('Enigma');

      expect(await repository.listAll(), hasLength(1));
      expect(created.name, 'Enigma');
    });

    test('reuses the existing franchise ignoring case and spacing', () async {
      final first = await repository.ensureByName('Enigma');
      final second = await repository.ensureByName('  eNiGmA ');

      expect(second.id, first.id);
      expect(await repository.listAll(), hasLength(1));
    });
  });

  test('updates name and logo', () async {
    final created = await repository.create(const FranchiseDraft(name: 'Old'));

    await repository.update(created.copyWith(name: 'New', logoPath: '/l.png'));

    final reloaded = await repository.findById(created.id);
    expect(reloaded?.name, 'New');
    expect(reloaded?.logoPath, '/l.png');
  });

  test(
    'deleting a franchise detaches its rooms instead of removing them',
    () async {
      final rooms = DriftRoomRepository(db);
      final franchise = await repository.create(
        const FranchiseDraft(name: 'E'),
      );
      final room = await rooms.create(
        RoomDraft(
          title: 'The Vault',
          happenedOn: DateTime(2026, 3, 1),
          escaped: true,
          franchiseId: franchise.id,
        ),
      );

      await repository.delete(franchise.id);

      final reloaded = await rooms.findById(room.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.franchiseId, isNull);
      expect(await repository.listAll(), isEmpty);
    },
  );
}
