import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/tracking/presentation/tracking_filter_controller.dart';
import '../data/drift_gig_repository.dart';
import '../domain/gig.dart';
import '../domain/gig_repository.dart';

final gigRepositoryProvider = Provider<GigRepository>(
  (ref) => DriftGigRepository(ref.watch(databaseProvider)),
);

final gigFilterProvider = NotifierProvider<GigFilterController, GigFilter>(
  GigFilterController.new,
);

class GigFilterController extends TrackingFilterController<GigFilter> {
  @override
  GigFilter get pristine => const GigFilter();

  void setCity(String? value) => state = value == null || value.isEmpty
      ? state.copyWith(clearCity: true)
      : state.copyWith(city: value);
}

final gigsProvider = StreamProvider<List<Gig>>((ref) {
  final filter = ref.watch(gigFilterProvider);
  return ref.watch(gigRepositoryProvider).watch(filter);
});

/// Every gig, unfiltered — stats describe the whole record, not the view.
final allGigsProvider = StreamProvider<List<Gig>>(
  (ref) => ref.watch(gigRepositoryProvider).watch(const GigFilter()),
);

final gigProvider = FutureProvider.family<Gig?, int>((ref, id) {
  ref.watch(allGigsProvider);
  return ref.watch(gigRepositoryProvider).findById(id);
});

/// The distinct cities already logged, for the city filter.
final gigCitiesProvider = Provider<List<String>>((ref) {
  final gigs = ref.watch(allGigsProvider).valueOrNull ?? const [];
  final seen = <String>{
    for (final gig in gigs)
      if (gig.city != null && gig.city!.trim().isNotEmpty) gig.city!.trim(),
  };
  return seen.toList()..sort();
});
