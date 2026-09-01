import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/tracking/presentation/tracking_filter_controller.dart';
import '../data/drift_viewing_repository.dart';
import '../domain/viewing.dart';
import '../domain/viewing_repository.dart';

final viewingRepositoryProvider = Provider<ViewingRepository>(
  (ref) => DriftViewingRepository(ref.watch(databaseProvider)),
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

final viewingProvider = FutureProvider.family<Viewing?, int>((ref, id) {
  ref.watch(allViewingsProvider);
  return ref.watch(viewingRepositoryProvider).findById(id);
});
