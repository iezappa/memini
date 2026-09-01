import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/games/data/drift_game_repository.dart';
import 'package:memini/features/games/domain/game.dart';
import 'package:memini/features/games/presentation/game_list_screen.dart';

import '../../support/harness.dart';

/// The list starts on a CircularProgressIndicator, whose animation never
/// stops — pumpAndSettle would wait for it forever.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late AppDatabase db;
  late DriftGameRepository games;

  setUp(() {
    db = memoryDatabase();
    games = DriftGameRepository(db);
  });

  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      await harness(const GameListScreen(), database: db),
    );
    await settle(tester);
  }

  testWidgets('shows the empty state when nothing is logged', (tester) async {
    await pump(tester);

    expect(find.text('No games logged'), findsOneWidget);
    expect(find.text('Add game'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('shows the title, platform, date, score and status', (
    tester,
  ) async {
    await games.create(
      GameDraft(
        title: 'Outer Wilds',
        status: GameStatus.hundredPercent,
        platform: 'PC',
        hoursPlayed: 27.5,
        rating: 10,
        happenedOn: DateTime(2026, 3, 14),
      ),
    );

    await pump(tester);

    expect(find.text('Outer Wilds'), findsOneWidget);
    expect(find.text('PC · Mar 14, 2026'), findsOneWidget);
    // The badge drops a trailing zero: a 10 reads as "10", not "10.0".
    expect(find.text('10'), findsOneWidget);
    expect(find.text('100% · 27.5h'), findsOneWidget);
    expect(find.text('1 GAME'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a whole number of hours drops the decimal', (tester) async {
    await games.create(
      GameDraft(
        title: 'Hades',
        status: GameStatus.finished,
        hoursPlayed: 40,
        happenedOn: DateTime(2026, 1, 1),
      ),
    );

    await pump(tester);

    expect(find.text('Finished · 40h'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the shared search narrows the list', (tester) async {
    await games.create(
      GameDraft(
        title: 'Outer Wilds',
        status: GameStatus.finished,
        happenedOn: DateTime(2026, 1, 1),
      ),
    );
    await games.create(
      GameDraft(
        title: 'Hades',
        status: GameStatus.finished,
        happenedOn: DateTime(2026, 1, 2),
      ),
    );

    await pump(tester);
    expect(find.text('2 GAMES'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'hades');
    await settle(tester);

    expect(find.text('Hades'), findsOneWidget);
    expect(find.text('Outer Wilds'), findsNothing);

    await unmount(tester);
  });

  testWidgets('a dropped game still shows up in the list', (tester) async {
    await games.create(
      GameDraft(
        title: 'Abandoned',
        status: GameStatus.dropped,
        happenedOn: DateTime(2026, 1, 1),
      ),
    );

    await pump(tester);

    expect(find.text('Abandoned'), findsOneWidget);
    expect(find.text('Dropped'), findsOneWidget);

    await unmount(tester);
  });
}
