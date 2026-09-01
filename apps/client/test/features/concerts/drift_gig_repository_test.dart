import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/concerts/data/drift_gig_repository.dart';
import 'package:memini/features/concerts/domain/gig.dart';
import 'package:memini/features/concerts/domain/gig_repository.dart';

void main() {
  late AppDatabase db;
  late DriftGigRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftGigRepository(db);
  });

  tearDown(() => db.close());

  Future<Gig> add({
    String title = 'Band',
    double? rating,
    DateTime? happenedOn,
    String? city,
    String? description,
    String? review,
  }) {
    return repository.create(
      GigDraft(
        title: title,
        happenedOn: happenedOn ?? DateTime(2026, 1, 1),
        rating: rating,
        city: city,
        description: description,
        review: review,
      ),
    );
  }

  Future<List<String>> titles(GigFilter filter) async =>
      (await repository.list(filter)).map((g) => g.title).toList();

  test('creates a gig and reads every field back', () async {
    final created = await repository.create(
      GigDraft(
        title: 'Radiohead',
        happenedOn: DateTime(2026, 3, 14, 22),
        photoPath: '/p.jpg',
        description: 'The OK Computer tour',
        rating: 10,
        review: 'Paranoid Android live is another thing',
        venue: 'Estadio Vélez',
        city: 'Buenos Aires',
        supportActs: 'Junun, Bombino',
        setlist: 'Bloom\nDaydreaming\nDecks Dark',
        company: 'Nico',
        externalId: 'a74b1b7f-71a5-4011-9441-d0b5e4122711',
      ),
    );

    final reloaded = await repository.findById(created.id);

    expect(reloaded!.title, 'Radiohead');
    expect(reloaded.venue, 'Estadio Vélez');
    expect(reloaded.city, 'Buenos Aires');
    expect(reloaded.supportActs, 'Junun, Bombino');
    expect(reloaded.setlist, contains('Daydreaming'));
    expect(reloaded.company, 'Nico');
    expect(reloaded.externalId, 'a74b1b7f-71a5-4011-9441-d0b5e4122711');
    expect(reloaded.happenedOn, DateTime(2026, 3, 14));
  });

  test('a multi-line setlist survives the round trip intact', () async {
    final created = await repository.create(
      GigDraft(
        title: 'Spinetta',
        happenedOn: DateTime(2026, 1, 1),
        setlist: 'Muchacha\nCantata de puentes amarillos\nDurazno sangrando',
      ),
    );

    final reloaded = await repository.findById(created.id);

    expect(reloaded!.setlist!.split('\n'), hasLength(3));
  });

  test(
    'inherits the shared search across title, description and review',
    () async {
      await add(title: 'Radiohead');
      await add(title: 'Cabin', description: 'Radiohead covers, oddly');
      await add(title: 'Unrelated');

      final result = await titles(const GigFilter(query: 'radiohead'));

      expect(result, hasLength(2));
      expect(result, isNot(contains('Unrelated')));
    },
  );

  test('inherits the shared ordering, newest night first by default', () async {
    await add(title: 'Older', happenedOn: DateTime(2024, 1, 1));
    await add(title: 'Newer', happenedOn: DateTime(2026, 1, 1));

    expect(await titles(const GigFilter()), ['Newer', 'Older']);
  });

  test('filters by city as a substring, ignoring case', () async {
    await add(title: 'Here', city: 'Buenos Aires');
    await add(title: 'Also here', city: 'buenos aires');
    await add(title: 'Away', city: 'Montevideo');

    final result = await titles(const GigFilter(city: 'BUENOS'));

    expect(result, hasLength(2));
    expect(result, isNot(contains('Away')));
  });

  test('deletes a gig', () async {
    final created = await add();
    await repository.delete(created.id);
    expect(await repository.findById(created.id), isNull);
  });

  test('watch emits again when a gig is added', () async {
    final seen = <int>[];
    final subscription = repository
        .watch(const GigFilter())
        .listen((rows) => seen.add(rows.length));

    await pumpEventQueue();
    await add();
    await pumpEventQueue();

    expect(seen, [0, 1]);
    await subscription.cancel();
  });
}
