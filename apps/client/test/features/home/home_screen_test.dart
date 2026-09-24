import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/dining/data/drift_meal_repository.dart';
import 'package:memini/features/dining/domain/meal.dart';
import 'package:memini/features/games/data/drift_game_repository.dart';
import 'package:memini/features/games/domain/game.dart';
import 'package:memini/features/home/presentation/home_screen.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';

import '../../support/harness.dart';

/// The hub starts on stream providers that have not emitted yet; pumping a
/// bounded number of frames lets them land without waiting on an animation.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = memoryDatabase();
  });

  tearDown(() => db.close());

  /// The default 800x600 test surface cuts the recent list short, and a
  /// ListView never builds rows it cannot show — so a taller window is what
  /// lets the assertions see every row.
  void useTallWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      await harness(const HomeScreen(), database: db, locale: locale),
    );
    await settle(tester);
  }

  testWidgets('shows a tile per domain, all at zero on a fresh install', (
    tester,
  ) async {
    await pump(tester);

    // Scoped to the grid: every domain is also a shortcut chip further
    // down, so its name is on the hub twice.
    Finder tile(String name) =>
        find.descendant(of: find.byType(GridView), matching: find.text(name));

    expect(tile('Escape rooms'), findsOneWidget);
    expect(tile('Places I ate'), findsOneWidget);
    expect(tile('Bands I saw'), findsOneWidget);
    expect(tile('Films and series'), findsOneWidget);
    expect(tile('Games'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(5));

    await unmount(tester);
  });

  testWidgets('counts each domain separately', (tester) async {
    await DriftRoomRepository(db).create(
      RoomDraft(
        title: 'The Vault',
        happenedOn: DateTime(2026, 1, 1),
        escaped: true,
      ),
    );
    final meals = DriftMealRepository(db);
    await meals.create(
      MealDraft(title: 'Don Julio', happenedOn: DateTime(2026, 1, 2)),
    );
    await meals.create(
      MealDraft(title: 'Chuí', happenedOn: DateTime(2026, 1, 3)),
    );

    await pump(tester);

    // One room, two meals, and the three untouched domains still at zero.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(3));

    await unmount(tester);
  });

  testWidgets('the recent list mixes domains, newest first', (tester) async {
    useTallWindow(tester);

    await DriftRoomRepository(db).create(
      RoomDraft(
        title: 'The Vault',
        happenedOn: DateTime(2026, 1, 1),
        escaped: true,
      ),
    );
    await DriftMealRepository(
      db,
    ).create(MealDraft(title: 'Don Julio', happenedOn: DateTime(2026, 3, 1)));
    await DriftGameRepository(db).create(
      GameDraft(
        title: 'Outer Wilds',
        status: GameStatus.finished,
        happenedOn: DateTime(2026, 2, 1),
      ),
    );

    await pump(tester);

    final titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();

    expect(titles, ['Don Julio', 'Outer Wilds', 'The Vault']);

    await unmount(tester);
  });

  testWidgets('says so when nothing has been logged in any domain', (
    tester,
  ) async {
    // The line sits under the grid, the tiles and the shortcuts now.
    useTallWindow(tester);
    await pump(tester);

    expect(
      find.text(
        'Nothing logged yet. Pick a section above and add the first one.',
      ),
      findsOneWidget,
    );

    await unmount(tester);
  });

  testWidgets('renders in Spanish when the locale is es', (tester) async {
    // Tall enough for the shortcuts under the tiles to be built.
    useTallWindow(tester);
    await pump(tester, locale: const Locale('es'));

    // Twice each: the tile and the shortcut under it.
    expect(find.text('Salas de escape'), findsNWidgets(2));
    expect(find.text('Lugares donde comí'), findsNWidgets(2));
    expect(find.text('Videojuegos'), findsNWidgets(2));

    await unmount(tester);
  });
}
