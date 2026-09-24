import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/clock.dart';
import '../../../core/enrichment/data/artwork_backfill.dart';
import '../../../core/enrichment/data/enrichment_providers.dart';
import '../../../core/tracking/presentation/tracking_filter_controller.dart';
import '../data/drift_viewing_repository.dart';
import '../domain/viewing.dart';
import '../domain/viewing_repository.dart';

final viewingRepositoryProvider = Provider<ViewingRepository>(
  (ref) => DriftViewingRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final viewingFilterProvider =
    NotifierProvider<ViewingFilterController, ViewingFilter>(
      ViewingFilterController.new,
    );

class ViewingFilterController extends TrackingFilterController<ViewingFilter> {
  @override
  ViewingFilter get pristine => const ViewingFilter();

  void setKind(ViewingKind? value) => state = value == null
      ? state.copyWith(clearKind: true)
      : state.copyWith(kind: value);
}

final viewingsProvider = StreamProvider<List<Viewing>>((ref) {
  final filter = ref.watch(viewingFilterProvider);
  return ref.watch(viewingRepositoryProvider).watch(filter);
});

/// Every viewing, unfiltered — stats describe the whole record, not the view.
final allViewingsProvider = StreamProvider<List<Viewing>>(
  (ref) => ref.watch(viewingRepositoryProvider).watch(const ViewingFilter()),
);

final viewingProvider = FutureProvider.family<Viewing?, String>((ref, id) {
  ref.watch(allViewingsProvider);
  return ref.watch(viewingRepositoryProvider).findById(id);
});

/// Fetches the artwork for an entry that was filled in from TMDB before the
/// app kept any, and writes it down once.
///
/// Watched by the detail screen, and keyed by the entry, so it runs once
/// per entry per launch and never for one that already has a picture or was
/// typed in by hand. What it returns is nothing: the point is the write,
/// and the screen redraws from the store like any other change.
final viewingArtworkProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final entry = await ref.watch(viewingProvider(id).future);
  if (entry == null) return;
  if (entry.posterUrl != null || entry.externalId == null) return;

  final found = await findArtwork(
    source: ref.watch(tmdbSourceProvider),
    title: entry.title,
    externalId: entry.externalId!,
  );
  if (found == null || found.posterUrl == null) return;

  await ref
      .watch(viewingRepositoryProvider)
      .update(
        entry.copyWith(
          posterUrl: found.posterUrl,
          backdropUrl: found.backdropUrl,
        ),
      );
  ref.invalidate(allViewingsProvider);
});
