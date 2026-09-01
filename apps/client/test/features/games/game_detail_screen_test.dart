import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/games/data/drift_game_repository.dart';
import 'package:memini/features/games/domain/game.dart';
import 'package:memini/features/games/domain/game_repository.dart';
import 'package:memini/features/games/presentation/game_detail_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftGameRepository entries;

  setUp(() {
    db = memoryDatabase();
    entries = DriftGameRepository(db);
  });
  tearDown(() => db.close());

  Future<Game> log() => entries.create(
    GameDraft(
      title: 'Outer Wilds',
      happenedOn: DateTime(2026, 1, 20),
      status: GameStatus.finished,
      hoursPlayed: 22.5,
      review: 'Nothing else is like it.',
    ),
  );

  Future<void> pumpDetail(WidgetTester tester, Game entry) =>
      pumpPushed(tester, GameDetailScreen(gameId: entry.id), database: db);

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
  }

  testWidgets('shows what was logged', (tester) async {
    await pumpDetail(tester, await log());

    expect(find.text('Outer Wilds'), findsWidgets);
    expect(find.text('Nothing else is like it.'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('warns that the delete cannot be undone', (tester) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);

    expect(
      find.text(
        'This game will be removed from your log. This cannot be undone.',
      ),
      findsOneWidget,
    );

    await unmount(tester);
  });

  testWidgets('leaves the entry alone when the delete is cancelled', (
    tester,
  ) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // There is no server and no undo: a delete that fires on a cancel takes
    // the entry with it for good.
    expect(await entries.list(const GameFilter()), hasLength(1));

    await unmount(tester);
  });

  testWidgets('deletes the entry once the delete is confirmed', (tester) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await entries.list(const GameFilter()), isEmpty);

    await unmount(tester);
  });
}
