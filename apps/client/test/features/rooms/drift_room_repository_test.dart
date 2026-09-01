import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/domain/tracking_filter.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/rooms/domain/room_repository.dart';

void main() {
  late AppDatabase db;
  late DriftRoomRepository repository;
  late DriftFranchiseRepository franchises;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRoomRepository(db);
    franchises = DriftFranchiseRepository(db);
  });

  tearDown(() => db.close());

  Future<Room> add({
    String title = 'Room',
    double? rating,
    bool escaped = true,
    DateTime? happenedOn,
    int? franchiseId,
    String? description,
    String? review,
  }) {
    return repository.create(
      RoomDraft(
        title: title,
        happenedOn: happenedOn ?? DateTime(2026, 1, 1),
        escaped: escaped,
        rating: rating,
        franchiseId: franchiseId,
        description: description,
        review: review,
      ),
    );
  }

  Future<List<String>> names(RoomFilter filter) async =>
      (await repository.list(filter)).map((r) => r.title).toList();

  test('creates a room and reads every field back', () async {
    final created = await repository.create(
      RoomDraft(
        title: 'The Vault',
        photoPath: '/p.jpg',
        description: 'A bank heist',
        rating: 9.5,
        review: 'Best one yet',
        happenedOn: DateTime(2026, 3, 14),
        escaped: true,
        timeLeftMinutes: 4,
      ),
    );

    final reloaded = await repository.findById(created.id);

    expect(reloaded!.title, 'The Vault');
    expect(reloaded.photoPath, '/p.jpg');
    expect(reloaded.description, 'A bank heist');
    expect(reloaded.rating, 9.5);
    expect(reloaded.review, 'Best one yet');
    expect(reloaded.happenedOn, DateTime(2026, 3, 14));
    expect(reloaded.escaped, isTrue);
    expect(reloaded.timeLeftMinutes, 4);
  });

  test('normalises happenedOn to midnight', () async {
    final created = await repository.create(
      RoomDraft(
        title: 'Late night',
        happenedOn: DateTime(2026, 3, 14, 23, 45),
        escaped: false,
      ),
    );

    expect(
      (await repository.findById(created.id))!.happenedOn,
      DateTime(2026, 3, 14),
    );
  });

  test('keeps the franchise link, which the list resolves to a name', () async {
    final franchise = await franchises.create(
      const FranchiseDraft(name: 'Enigma'),
    );
    await add(title: 'The Vault', franchiseId: franchise.id);
    await add(title: 'Loose room');

    final rows = await repository.list(
      const RoomFilter(sort: TrackingSort.titleAsc),
    );

    expect(rows.first.franchiseId, isNull); // 'Loose room'
    expect(rows.last.franchiseId, franchise.id); // 'The Vault'
  });

  group('sorting', () {
    test('defaults to most recently played first', () async {
      await add(title: 'Older', happenedOn: DateTime(2024, 1, 1));
      await add(title: 'Newer', happenedOn: DateTime(2026, 1, 1));

      expect(await names(const RoomFilter()), ['Newer', 'Older']);
    });

    test('ratingDesc puts unrated rooms last, never first', () async {
      await add(title: 'Unrated');
      await add(title: 'Great', rating: 9);
      await add(title: 'Poor', rating: 3);

      expect(await names(const RoomFilter(sort: TrackingSort.ratingDesc)), [
        'Great',
        'Poor',
        'Unrated',
      ]);
    });

    test('ratingAsc also puts unrated rooms last', () async {
      await add(title: 'Unrated');
      await add(title: 'Great', rating: 9);
      await add(title: 'Poor', rating: 3);

      expect(await names(const RoomFilter(sort: TrackingSort.ratingAsc)), [
        'Poor',
        'Great',
        'Unrated',
      ]);
    });

    test('titleAsc ignores case', () async {
      await add(title: 'zeta');
      await add(title: 'Alpha');

      expect(await names(const RoomFilter(sort: TrackingSort.titleAsc)), [
        'Alpha',
        'zeta',
      ]);
    });
  });

  group('filtering', () {
    test('matches the query against title, description and review', () async {
      await add(title: 'The Vault');
      await add(title: 'Cabin', description: 'A vault in the woods');
      await add(title: 'Prison', review: 'Felt like a VAULT');
      await add(title: 'Unrelated');

      final result = await names(const RoomFilter(query: 'vault'));

      expect(result, hasLength(3));
      expect(result, isNot(contains('Unrelated')));
    });

    test('ignores a blank query', () async {
      await add(title: 'Only');

      expect(await names(const RoomFilter(query: '   ')), ['Only']);
    });

    test('filters by franchise', () async {
      final franchise = await franchises.create(
        const FranchiseDraft(name: 'Enigma'),
      );
      await add(title: 'Mine', franchiseId: franchise.id);
      await add(title: 'Theirs');

      expect(await names(RoomFilter(franchiseId: franchise.id)), ['Mine']);
    });

    test('filters by escaped', () async {
      await add(title: 'Won', escaped: true);
      await add(title: 'Lost', escaped: false);

      expect(await names(const RoomFilter(escaped: false)), ['Lost']);
    });

    test('filters by minimum rating and excludes unrated rooms', () async {
      await add(title: 'Great', rating: 9);
      await add(title: 'Poor', rating: 3);
      await add(title: 'Unrated');

      expect(await names(const RoomFilter(minRating: 8)), ['Great']);
    });
  });

  test('updates a room and can clear its optional fields', () async {
    final created = await add(title: 'Old', rating: 5);

    await repository.update(
      created.copyWith(title: 'New', clearRating: true, escaped: false),
    );

    final reloaded = await repository.findById(created.id);
    expect(reloaded!.title, 'New');
    expect(reloaded.rating, isNull);
    expect(reloaded.escaped, isFalse);
  });

  test('deletes a room', () async {
    final created = await add();

    await repository.delete(created.id);

    expect(await repository.findById(created.id), isNull);
  });

  test('watch emits again when a room is added', () async {
    final seen = <int>[];
    final subscription = repository
        .watch(const RoomFilter())
        .listen((rows) => seen.add(rows.length));

    // Let the initial (empty) emission land before mutating the table.
    await pumpEventQueue();
    await add();
    await pumpEventQueue();

    expect(seen, [0, 1]);
    await subscription.cancel();
  });
}
