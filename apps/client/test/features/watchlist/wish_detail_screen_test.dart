import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/screen/data/drift_viewing_repository.dart';
import 'package:memini/features/screen/domain/viewing_repository.dart';
import 'package:memini/features/watchlist/data/drift_wish_repository.dart';
import 'package:memini/features/watchlist/domain/wish.dart';
import 'package:memini/features/watchlist/presentation/wish_detail_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftWishRepository wishes;

  setUp(() {
    db = memoryDatabase();
    wishes = DriftWishRepository(db);
  });
  tearDown(() => db.close());

  Future<Wish> add({WishKind kind = WishKind.screen, String? note}) {
    return wishes.create(
      WishDraft(
        kind: kind,
        title: 'Dune: Part Three',
        addedOn: DateTime(2026, 3, 1),
        note: note,
        description: 'A spice merchant on Arrakis',
        releaseYear: 2027,
      ),
    );
  }

  Future<void> pump(WidgetTester tester, Wish wish) async {
    useTallSurface(tester);
    await tester.pumpWidget(
      await harness(WishDetailScreen(wishId: wish.id), database: db),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows what it is, why it is here and when it went on', (
    tester,
  ) async {
    final wish = await add(note: 'My sister will not stop talking about it');

    await pump(tester, wish);

    expect(find.text('Dune: Part Three'), findsOneWidget);
    expect(find.text('Film or series · 2027'), findsOneWidget);
    expect(
      find.text('My sister will not stop talking about it'),
      findsOneWidget,
    );
    expect(find.text('A spice merchant on Arrakis'), findsOneWidget);
    expect(find.text('Added Mar 1, 2026'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the button says the right thing for a game', (tester) async {
    final wish = await add(kind: WishKind.game);

    await pump(tester, wish);

    expect(find.text('I have played it'), findsOneWidget);
    expect(find.text('I have seen it'), findsNothing);
    await unmount(tester);
  });

  testWidgets('marking it seen moves it into the section it belongs to', (
    tester,
  ) async {
    final wish = await add();
    await pump(tester, wish);

    await tester.tap(find.text('I have seen it'));
    await tester.pumpAndSettle();

    final viewings = await DriftViewingRepository(db)
        .list(const ViewingFilter());
    expect(viewings.single.title, 'Dune: Part Three');
    expect(await wishes.list(const WishFilter()), isEmpty);
    await unmount(tester);
  });

  testWidgets('removing asks first', (tester) async {
    final wish = await add();
    await pump(tester, wish);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.textContaining('off the watchlist?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await wishes.list(const WishFilter()), hasLength(1));
    await unmount(tester);
  });
}
