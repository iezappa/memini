import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/time/clock.dart';
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
    DateTime? today,
  }) async {
    await tester.pumpWidget(
      await harness(
        const HomeScreen(),
        database: db,
        locale: locale,
        overrides: [
          if (today != null) clockProvider.overrideWithValue(() => today),
        ],
      ),
    );
    await settle(tester);
  }

  testWidgets('offers a shortcut per domain, and the figures empty', (
    tester,
  ) async {
    // The hub is a page now — grid, figures, shortcuts, suggestions and the
    // recent list — and a ListView builds only what fits.
    useTallWindow(tester);
    await pump(tester);

    // One shortcut per domain, straight to its form. The tiles that used to
    // print a count per domain are gone: with a tab per section they were a
    // second copy of the navigation.
    Finder shortcut(String name) => find.widgetWithText(ActionChip, name);

    expect(shortcut('Escape rooms'), findsOneWidget);
    expect(shortcut('Places I ate'), findsOneWidget);
    expect(shortcut('Bands I saw'), findsOneWidget);
    expect(shortcut('Films and series'), findsOneWidget);
    expect(shortcut('Games'), findsOneWidget);

    // And the figures that replaced them, all empty on a fresh install.
    expect(find.text('Logged'), findsOneWidget);
    expect(find.text('Average score'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2), reason: 'logged and this month');
    expect(find.text('—'), findsOneWidget, reason: 'no scores is not zero');

    await unmount(tester);
  });

  testWidgets('prints the collection as three figures', (tester) async {
    // What the per-domain tiles used to say is the navigation's job now.
    // These are the things it cannot say.
    await DriftRoomRepository(db).create(
      RoomDraft(
        title: 'The Vault',
        happenedOn: DateTime(2026, 1, 1),
        escaped: true,
      ),
    );
    final meals = DriftMealRepository(db);
    await meals.create(
      MealDraft(
        title: 'Don Julio',
        happenedOn: DateTime(2026, 1, 2),
        rating: 8,
      ),
    );
    await meals.create(
      MealDraft(title: 'Chuí', happenedOn: DateTime(2026, 9, 3), rating: 9),
    );

    useTallWindow(tester);
    await pump(tester, today: DateTime(2026, 9, 20));

    expect(find.text('3'), findsOneWidget, reason: 'logged');
    expect(find.text('8.5'), findsOneWidget, reason: 'of the two that scored');
    expect(find.text('1'), findsOneWidget, reason: 'the one in September');

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

    expect(find.text('Salas de escape'), findsOneWidget);
    expect(find.text('Lugares donde comí'), findsOneWidget);
    expect(find.text('Videojuegos'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('asks for a key before it offers suggestions', (tester) async {
    // With no TMDB or RAWG key there is nothing to ask for, and the shelf
    // says what to do about it instead of sitting empty.
    useTallWindow(tester);
    await pump(tester);

    expect(
      find.text('Add your TMDB or RAWG key in Settings to see suggestions.'),
      findsOneWidget,
    );

    await unmount(tester);
  });
}
