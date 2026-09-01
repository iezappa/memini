import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/games/data/drift_game_repository.dart';
import 'package:memini/features/games/domain/game.dart';
import 'package:memini/features/games/domain/game_repository.dart';
import 'package:memini/features/games/presentation/game_form_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftGameRepository games;

  setUp(() {
    db = memoryDatabase();
    games = DriftGameRepository(db);
  });
  tearDown(() => db.close());

  Future<void> pumpForm(WidgetTester tester, {Game? game}) =>
      pumpPushed(tester, GameFormScreen(game: game), database: db);

  Future<void> chooseStatus(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('will not save a game with no title', (tester) async {
    await pumpForm(tester);

    await tapSave(tester);

    expect(find.text('It needs a title'), findsOneWidget);
    expect(await games.list(const GameFilter()), isEmpty);

    await unmount(tester);
  });

  testWidgets('reads hours written with a comma', (tester) async {
    await pumpForm(tester);

    await fillField(tester, 'Title', 'Outer Wilds');
    // A comma is the decimal separator here. Parsed naively this would drop
    // the hours entirely rather than record them.
    await fillField(tester, 'Hours played', '22,5');
    await tapSave(tester);

    expect((await games.list(const GameFilter())).single.hoursPlayed, 22.5);

    await unmount(tester);
  });

  testWidgets('records the status, the platform and the year', (tester) async {
    await pumpForm(tester);

    await fillField(tester, 'Title', 'Outer Wilds');
    await chooseStatus(tester, 'Finished');
    await fillField(tester, 'Platform', 'Steam Deck');
    await fillField(tester, 'Release year', '2019');
    await tapSave(tester);

    final saved = (await games.list(const GameFilter())).single;
    expect(saved.status, GameStatus.finished);
    expect(saved.platform, 'Steam Deck');
    expect(saved.releaseYear, 2019);

    await unmount(tester);
  });

  testWidgets('leaves an untimed game without hours, not at zero', (
    tester,
  ) async {
    await pumpForm(tester);

    await fillField(tester, 'Title', 'Outer Wilds');
    await tapSave(tester);

    final saved = (await games.list(const GameFilter())).single;
    expect(saved.hoursPlayed, isNull);
    expect(saved.platform, isNull);
    expect(saved.rating, isNull);

    await unmount(tester);
  });

  testWidgets('opens on the game being edited and updates it in place', (
    tester,
  ) async {
    final original = await games.create(
      GameDraft(
        title: 'Outer Wilds',
        happenedOn: DateTime(2026, 1, 20),
        status: GameStatus.playing,
        hoursPlayed: 10,
      ),
    );

    await pumpForm(tester, game: original);

    await chooseStatus(tester, 'Finished');
    await fillField(tester, 'Hours played', '22,5');
    await tapSave(tester);

    final all = await games.list(const GameFilter());
    expect(all, hasLength(1), reason: 'editing must update, never insert');
    expect(all.single.id, original.id);
    expect(all.single.status, GameStatus.finished);
    expect(all.single.hoursPlayed, 22.5);

    await unmount(tester);
  });
}
