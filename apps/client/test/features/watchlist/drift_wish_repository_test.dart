import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/domain/tracking_filter.dart';
import 'package:memini/features/watchlist/data/drift_wish_repository.dart';
import 'package:memini/features/watchlist/domain/wish.dart';

void main() {
  late AppDatabase db;
  late DriftWishRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWishRepository(db, now: () => DateTime(2026, 9, 25));
  });
  tearDown(() => db.close());

  Future<Wish> add({
    String title = 'Dune: Part Three',
    WishKind kind = WishKind.screen,
    DateTime? addedOn,
    String? note,
    String? description,
    int? releaseYear,
  }) {
    return repository.create(
      WishDraft(
        kind: kind,
        title: title,
        addedOn: addedOn ?? DateTime(2026, 9, 25),
        note: note,
        description: description,
        releaseYear: releaseYear,
      ),
    );
  }

  test('keeps what a wish is for, and when it was added', () async {
    final wish = await add(
      note: 'The one my sister will not stop talking about',
      releaseYear: 2027,
    );

    final stored = await repository.findById(wish.id);

    expect(stored!.title, 'Dune: Part Three');
    expect(stored.kind, WishKind.screen);
    expect(stored.note, 'The one my sister will not stop talking about');
    expect(stored.releaseYear, 2027);
    expect(stored.addedOn, DateTime(2026, 9, 25));
  });

  test('the newest addition is at the top', () async {
    await add(title: 'First', addedOn: DateTime(2026, 1, 1));
    await add(title: 'Last', addedOn: DateTime(2026, 9, 1));

    final list = await repository.list(const WishFilter());

    expect(list.map((w) => w.title), ['Last', 'First']);
  });

  test('the list can be read the other way round', () async {
    await add(title: 'First', addedOn: DateTime(2026, 1, 1));
    await add(title: 'Last', addedOn: DateTime(2026, 9, 1));

    final list = await repository.list(
      const WishFilter(sort: TrackingSort.happenedOnAsc),
    );

    expect(list.map((w) => w.title), ['First', 'Last']);
  });

  test('one kind at a time', () async {
    await add(title: 'Silksong', kind: WishKind.game);
    await add(title: 'Dune: Part Three');

    final games = await repository.list(
      const WishFilter(kind: WishKind.game),
    );

    expect(games.map((w) => w.title), ['Silksong']);
  });

  test('the search reaches the note, which is how people look', () async {
    await add(title: 'Some Film', note: 'the one my sister recommended');
    await add(title: 'Another');

    final found = await repository.list(const WishFilter(query: 'sister'));

    expect(found.map((w) => w.title), ['Some Film']);
  });

  test('the search also reaches the synopsis', () async {
    await add(title: 'Some Film', description: 'A spice merchant on Arrakis');

    final found = await repository.list(const WishFilter(query: 'arrakis'));

    expect(found, hasLength(1));
  });

  test('editing keeps the day it was added', () async {
    final wish = await add(addedOn: DateTime(2026, 3, 1));

    await repository.update(wish.copyWith(title: 'Renamed'));

    final stored = await repository.findById(wish.id);
    expect(stored!.title, 'Renamed');
    expect(stored.addedOn, DateTime(2026, 3, 1));
  });

  test('taking one off leaves the rest', () async {
    final wish = await add(title: 'Gone');
    await add(title: 'Stays');

    await repository.delete(wish.id);

    expect(
      (await repository.list(const WishFilter())).map((w) => w.title),
      ['Stays'],
    );
  });
}
