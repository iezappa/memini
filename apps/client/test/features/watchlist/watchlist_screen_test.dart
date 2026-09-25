import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/presentation/tracker_card.dart';
import 'package:memini/features/watchlist/data/drift_wish_repository.dart';
import 'package:memini/features/watchlist/domain/wish.dart';
import 'package:memini/features/watchlist/presentation/watchlist_screen.dart';

import '../../support/harness.dart';

/// The list opens on a spinner whose animation never stops.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<Wish> add({
    String title = 'Dune: Part Three',
    WishKind kind = WishKind.screen,
    int? releaseYear,
  }) {
    return DriftWishRepository(db).create(
      WishDraft(
        kind: kind,
        title: title,
        addedOn: DateTime(2026, 9, 25),
        releaseYear: releaseYear,
      ),
    );
  }

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    useTallSurface(tester);
    await tester.pumpWidget(
      await harness(
        const WatchlistScreen(),
        database: db,
        locale: locale ?? const Locale('en'),
      ),
    );
    await settle(tester);
  }

  testWidgets('says what the list is for before anything is on it', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Nothing waiting yet'), findsOneWidget);
    expect(find.text('Add to watchlist'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a wish shows what kind of thing it is and when it went on', (
    tester,
  ) async {
    await add(releaseYear: 2027);

    await pump(tester);

    expect(find.text('Dune: Part Three'), findsOneWidget);
    expect(
      find.text('Film or series · 2027 · Sep 25, 2026'),
      findsOneWidget,
    );
    await unmount(tester);
  });

  testWidgets('nothing on the list carries a score', (tester) async {
    await add();

    await pump(tester);

    final card = tester.widget<TrackerCard>(find.byType(TrackerCard));
    expect(card.rating, isNull);
    // Nor a photo owner: a wish is a thing that has not happened.
    expect(card.photoOwnerId, isNull);
    await unmount(tester);
  });

  testWidgets('the kind filter narrows the list to one sort of thing', (
    tester,
  ) async {
    await add(title: 'Silksong', kind: WishKind.game);
    await add(title: 'Dune: Part Three');
    await pump(tester);

    await tester.tap(find.text('Everything'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Game').last);
    await settle(tester);

    expect(find.text('Silksong'), findsOneWidget);
    expect(find.text('Dune: Part Three'), findsNothing);
    await unmount(tester);
  });

  testWidgets('the search reads the list, not the sections', (tester) async {
    await add(title: 'Silksong', kind: WishKind.game);
    await add(title: 'Dune: Part Three');
    await pump(tester);

    await tester.enterText(find.byType(TextField), 'silk');
    await settle(tester);

    expect(find.text('Silksong'), findsOneWidget);
    expect(find.text('Dune: Part Three'), findsNothing);
    await unmount(tester);
  });

  testWidgets('it reads in Spanish too', (tester) async {
    await add();

    await pump(tester, locale: const Locale('es'));

    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('1 cosa pendiente'.toUpperCase()), findsOneWidget);
    await unmount(tester);
  });
}
