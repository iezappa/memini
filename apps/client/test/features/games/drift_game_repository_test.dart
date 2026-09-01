import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/domain/tracking_filter.dart';
import 'package:memini/features/games/data/drift_game_repository.dart';
import 'package:memini/features/games/domain/game.dart';
import 'package:memini/features/games/domain/game_repository.dart';

void main() {
  late AppDatabase db;
  late DriftGameRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftGameRepository(db);
  });

  tearDown(() => db.close());

  Future<Game> add({
    String title = 'Game',
    GameStatus status = GameStatus.finished,
    double? rating,
    DateTime? happenedOn,
    String? platform,
    String? description,
    String? review,
  }) {
    return repository.create(
      GameDraft(
        title: title,
        status: status,
        happenedOn: happenedOn ?? DateTime(2026, 1, 1),
        rating: rating,
        platform: platform,
        description: description,
        review: review,
      ),
    );
  }

  Future<List<String>> titles(GameFilter filter) async =>
      (await repository.list(filter)).map((g) => g.title).toList();

  test('creates a game and reads every field back', () async {
    final created = await repository.create(
      GameDraft(
        title: 'Outer Wilds',
        status: GameStatus.hundredPercent,
        happenedOn: DateTime(2026, 3, 14, 2),
        photoPath: '/cover.jpg',
        description: 'A 22 minute loop',
        rating: 10,
        review: 'Nothing else is like it',
        platform: 'PC',
        hoursPlayed: 27.5,
        releaseYear: 2019,
        externalId: '22511',
      ),
    );

    final reloaded = await repository.findById(created.id);

    expect(reloaded!.title, 'Outer Wilds');
    expect(reloaded.status, GameStatus.hundredPercent);
    expect(reloaded.platform, 'PC');
    expect(
      reloaded.hoursPlayed,
      27.5,
      reason: 'hours are fractional on purpose',
    );
    expect(reloaded.releaseYear, 2019);
    expect(reloaded.externalId, '22511');
    expect(reloaded.happenedOn, DateTime(2026, 3, 14));
  });

  test('a dropped game is a first-class entry, not a missing one', () async {
    await add(title: 'Abandoned', status: GameStatus.dropped, rating: 3);

    final dropped = await repository.list(
      const GameFilter(status: GameStatus.dropped),
    );

    expect(dropped.single.title, 'Abandoned');
    expect(dropped.single.isFinished, isFalse);
  });

  test('isFinished covers both finished and hundredPercent', () async {
    final finished = await add(title: 'Done', status: GameStatus.finished);
    final full = await add(
      title: 'All of it',
      status: GameStatus.hundredPercent,
    );
    final playing = await add(title: 'Ongoing', status: GameStatus.playing);

    expect(finished.isFinished, isTrue);
    expect(full.isFinished, isTrue);
    expect(playing.isFinished, isFalse);
  });

  test('filters by status', () async {
    await add(title: 'Done', status: GameStatus.finished);
    await add(title: 'Ongoing', status: GameStatus.playing);

    expect(await titles(const GameFilter(status: GameStatus.playing)), [
      'Ongoing',
    ]);
  });

  test('filters by platform as a substring, ignoring case', () async {
    await add(title: 'On Switch', platform: 'Nintendo Switch');
    await add(title: 'Also Switch', platform: 'switch');
    await add(title: 'On PC', platform: 'PC');

    final result = await titles(const GameFilter(platform: 'SWITCH'));

    expect(result, hasLength(2));
    expect(result, isNot(contains('On PC')));
  });

  test('inherits the shared search and ordering', () async {
    await add(title: 'Hades', rating: 9);
    await add(title: 'Cabin', description: 'Hades but cosy', rating: 4);
    await add(title: 'Unrelated', rating: 10);

    final result = await titles(
      const GameFilter(query: 'hades', sort: TrackingSort.ratingDesc),
    );

    expect(result, ['Hades', 'Cabin']);
  });

  test('deletes a game', () async {
    final created = await add();
    await repository.delete(created.id);
    expect(await repository.findById(created.id), isNull);
  });

  test('watch emits again when a game is added', () async {
    final seen = <int>[];
    final subscription = repository
        .watch(const GameFilter())
        .listen((rows) => seen.add(rows.length));

    await pumpEventQueue();
    await add();
    await pumpEventQueue();

    expect(seen, [0, 1]);
    await subscription.cancel();
  });
}
