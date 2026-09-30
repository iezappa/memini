import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/domain/tracked_domain.dart';
import 'package:memini/features/concerts/domain/gig_repository.dart';
import 'package:memini/features/concerts/presentation/gig_providers.dart';
import 'package:memini/features/games/domain/game_repository.dart';
import 'package:memini/features/games/presentation/game_providers.dart';
import 'package:memini/features/screen/domain/viewing_repository.dart';
import 'package:memini/features/screen/presentation/viewing_providers.dart';
import 'package:memini/features/watchlist/domain/wish.dart';
import 'package:memini/features/watchlist/presentation/wish_fulfilment.dart';
import 'package:memini/features/watchlist/presentation/wish_providers.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = memoryDatabase();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
  });
  tearDown(() => db.close());

  Future<Wish> wish(WishKind kind) => container
      .read(wishRepositoryProvider)
      .create(
        WishDraft(
          kind: kind,
          title: 'Dune: Part Three',
          addedOn: DateTime(2026, 3, 1),
          description: 'A spice merchant on Arrakis',
          releaseYear: 2027,
          externalId: '438631',
          posterUrl: 'https://image.tmdb.org/t/p/w500/dune.jpg',
        ),
      );

  test('a film wished for becomes a film watched, today', () async {
    final pending = await wish(WishKind.screen);

    final moved = await container
        .read(wishFulfilmentProvider)
        .fulfil(pending, on: DateTime(2026, 9, 25));

    expect(moved.domain, TrackedDomain.screen);

    final viewing =
        (await container
                .read(viewingRepositoryProvider)
                .list(const ViewingFilter()))
            .single;
    expect(viewing.id, moved.id);
    expect(viewing.title, 'Dune: Part Three');
    expect(viewing.happenedOn, DateTime(2026, 9, 25));
    // Everything the lookup had found comes across.
    expect(viewing.description, 'A spice merchant on Arrakis');
    expect(viewing.releaseYear, 2027);
    expect(viewing.externalId, '438631');
    expect(viewing.posterUrl, 'https://image.tmdb.org/t/p/w500/dune.jpg');
    // The score is the one thing only the owner can supply.
    expect(viewing.rating, isNull);
  });

  test('and comes off the watchlist', () async {
    final pending = await wish(WishKind.screen);

    await container.read(wishFulfilmentProvider).fulfil(pending);

    expect(
      await container.read(wishRepositoryProvider).list(const WishFilter()),
      isEmpty,
    );
  });

  test('a game lands in games, with its cover', () async {
    final pending = await wish(WishKind.game);

    final moved = await container.read(wishFulfilmentProvider).fulfil(pending);

    expect(moved.domain, TrackedDomain.games);
    final game =
        (await container.read(gameRepositoryProvider).list(const GameFilter()))
            .single;
    expect(game.title, 'Dune: Part Three');
    expect(game.coverUrl, 'https://image.tmdb.org/t/p/w500/dune.jpg');
    expect(game.rating, isNull);
  });

  test('a band lands in concerts', () async {
    final pending = await wish(WishKind.music);

    final moved = await container.read(wishFulfilmentProvider).fulfil(pending);

    expect(moved.domain, TrackedDomain.concerts);
    final gig =
        (await container.read(gigRepositoryProvider).list(const GigFilter()))
            .single;
    expect(gig.title, 'Dune: Part Three');
    expect(gig.externalId, '438631');
  });
}
