import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tracking/domain/tracked_domain.dart';
import '../../concerts/domain/gig.dart';
import '../../concerts/presentation/gig_providers.dart';
import '../../games/domain/game.dart';
import '../../games/presentation/game_providers.dart';
import '../../screen/domain/viewing.dart';
import '../../screen/presentation/viewing_providers.dart';
import '../domain/wish.dart';
import 'wish_providers.dart';

/// What a fulfilled wish became: which section it landed in, and the id of
/// the entry there, so the message about it can offer to open it.
typedef Fulfilled = ({TrackedDomain domain, String id});

/// Turns a wish into a real entry and takes it off the list.
///
/// Dated today and left unrated on purpose. The day is a guess the owner can
/// correct in one tap; a score is not something anything but they can supply,
/// and a wish arriving pre-rated would be a lie about what they thought of
/// it. Everything the lookup found — the synopsis, the year, the id and the
/// artwork — comes across, so the entry opens complete.
class WishFulfilment {
  WishFulfilment(this._ref);

  final Ref _ref;

  Future<Fulfilled> fulfil(Wish wish, {DateTime? on}) async {
    final today = on ?? DateTime.now();

    final fulfilled = switch (wish.kind) {
      WishKind.screen => (
        domain: TrackedDomain.screen,
        id: (await _ref.read(viewingRepositoryProvider).create(
          ViewingDraft(
            title: wish.title,
            happenedOn: today,
            // The coarse guess: a wish does not say whether it is a film or
            // a series, and the owner can correct it where they add the
            // score.
            kind: ViewingKind.film,
            description: wish.description,
            releaseYear: wish.releaseYear,
            externalId: wish.externalId,
            posterUrl: wish.posterUrl,
          ),
        )).id,
      ),
      WishKind.game => (
        domain: TrackedDomain.games,
        id: (await _ref.read(gameRepositoryProvider).create(
          GameDraft(
            title: wish.title,
            happenedOn: today,
            status: GameStatus.finished,
            description: wish.description,
            releaseYear: wish.releaseYear,
            externalId: wish.externalId,
            coverUrl: wish.posterUrl,
          ),
        )).id,
      ),
      WishKind.music => (
        domain: TrackedDomain.concerts,
        id: (await _ref.read(gigRepositoryProvider).create(
          GigDraft(
            title: wish.title,
            happenedOn: today,
            description: wish.description,
            externalId: wish.externalId,
          ),
        )).id,
      ),
    };

    // Last, and only once the entry exists: a wish removed before the write
    // that replaces it would be a wish lost to a full disk.
    await _ref.read(wishRepositoryProvider).delete(wish.id);

    return fulfilled;
  }
}

final wishFulfilmentProvider = Provider<WishFulfilment>(WishFulfilment.new);
