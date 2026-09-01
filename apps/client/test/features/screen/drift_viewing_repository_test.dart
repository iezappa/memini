import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/domain/tracking_filter.dart';
import 'package:memini/features/screen/data/drift_viewing_repository.dart';
import 'package:memini/features/screen/domain/viewing.dart';
import 'package:memini/features/screen/domain/viewing_repository.dart';

void main() {
  late AppDatabase db;
  late DriftViewingRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftViewingRepository(db);
  });

  tearDown(() => db.close());

  Future<Viewing> add({
    String title = 'Title',
    ViewingKind kind = ViewingKind.film,
    double? rating,
    DateTime? happenedOn,
    String? description,
    String? review,
    int? season,
  }) {
    return repository.create(
      ViewingDraft(
        title: title,
        kind: kind,
        happenedOn: happenedOn ?? DateTime(2026, 1, 1),
        rating: rating,
        description: description,
        review: review,
        season: season,
      ),
    );
  }

  Future<List<String>> titles(ViewingFilter filter) async =>
      (await repository.list(filter)).map((v) => v.title).toList();

  test('creates a viewing and reads every field back', () async {
    final created = await repository.create(
      ViewingDraft(
        title: 'Blade Runner 2049',
        kind: ViewingKind.film,
        happenedOn: DateTime(2026, 3, 14, 20),
        photoPath: '/poster.jpg',
        description: 'A blade runner unearths a secret',
        rating: 9,
        review: 'Deakins earned that Oscar',
        releaseYear: 2017,
        director: 'Denis Villeneuve',
        cast: 'Ryan Gosling, Harrison Ford, Ana de Armas',
        externalId: '335984',
      ),
    );

    final reloaded = await repository.findById(created.id);

    expect(reloaded!.title, 'Blade Runner 2049');
    expect(reloaded.kind, ViewingKind.film);
    expect(reloaded.releaseYear, 2017);
    expect(reloaded.director, 'Denis Villeneuve');
    expect(reloaded.cast, contains('Ana de Armas'));
    expect(reloaded.externalId, '335984');
    expect(reloaded.season, isNull);
    expect(reloaded.happenedOn, DateTime(2026, 3, 14));
  });

  test('the kind survives the round trip as the enum, not an index', () async {
    final created = await add(title: 'Chernobyl', kind: ViewingKind.miniseries);

    expect(
      (await repository.findById(created.id))!.kind,
      ViewingKind.miniseries,
    );
  });

  test('a series can be logged once per season', () async {
    await add(title: 'Severance', kind: ViewingKind.series, season: 1);
    await add(title: 'Severance', kind: ViewingKind.series, season: 2);

    final rows = await repository.list(const ViewingFilter());

    expect(rows, hasLength(2));
    expect(rows.map((v) => v.season), containsAll([1, 2]));
  });

  test('filters by kind', () async {
    await add(title: 'A film', kind: ViewingKind.film);
    await add(title: 'A series', kind: ViewingKind.series);
    await add(title: 'A doc', kind: ViewingKind.documentary);

    expect(await titles(const ViewingFilter(kind: ViewingKind.series)), [
      'A series',
    ]);
  });

  test('inherits the shared search and ordering', () async {
    await add(title: 'Dune', rating: 9);
    await add(title: 'Cabin', description: 'Dune but in a cabin', rating: 4);
    await add(title: 'Unrelated', rating: 10);

    final result = await titles(
      const ViewingFilter(query: 'dune', sort: TrackingSort.ratingDesc),
    );

    expect(result, ['Dune', 'Cabin']);
  });

  test('deletes a viewing', () async {
    final created = await add();
    await repository.delete(created.id);
    expect(await repository.findById(created.id), isNull);
  });

  test('watch emits again when a viewing is added', () async {
    final seen = <int>[];
    final subscription = repository
        .watch(const ViewingFilter())
        .listen((rows) => seen.add(rows.length));

    await pumpEventQueue();
    await add();
    await pumpEventQueue();

    expect(seen, [0, 1]);
    await subscription.cancel();
  });
}
