import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/enrichment/data/enrichment_providers.dart';
import '../../../core/enrichment/domain/enrichment.dart';
import '../../../core/time/clock.dart';
import '../../../core/tracking/presentation/tracking_filter_controller.dart';
import '../data/drift_wish_repository.dart';
import '../domain/wish.dart';

final wishRepositoryProvider = Provider<WishRepository>(
  (ref) => DriftWishRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final wishFilterProvider = NotifierProvider<WishFilterController, WishFilter>(
  WishFilterController.new,
);

class WishFilterController extends TrackingFilterController<WishFilter> {
  @override
  WishFilter get pristine => const WishFilter();

  void setKind(WishKind? value) => state = value == null
      ? state.copyWith(clearKind: true)
      : state.copyWith(kind: value);
}

final wishesProvider = StreamProvider<List<Wish>>((ref) {
  final filter = ref.watch(wishFilterProvider);

  return ref.watch(wishRepositoryProvider).watch(filter);
});

/// The whole watchlist, unfiltered — for counting, which describes the list
/// rather than the view of it.
final allWishesProvider = StreamProvider<List<Wish>>(
  (ref) => ref.watch(wishRepositoryProvider).watch(const WishFilter()),
);

final wishProvider = FutureProvider.family<Wish?, String>((ref, id) {
  ref.watch(allWishesProvider);

  return ref.watch(wishRepositoryProvider).findById(id);
});

/// Where to look a wish of this kind up, or null when nothing free covers it.
EnrichmentSource enrichmentSourceForWish(WidgetRef ref, WishKind kind) =>
    switch (kind) {
      WishKind.screen => ref.watch(tmdbSourceProvider),
      WishKind.game => ref.watch(rawgSourceProvider),
      WishKind.music => ref.watch(musicBrainzSourceProvider),
    };
