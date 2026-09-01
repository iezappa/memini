import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/tracking_filter.dart';

/// The filter behaviour every domain shares.
///
/// Search, minimum rating, ordering and "clear" work the same everywhere, so
/// each feature only has to add the setters for its own fields.
abstract class TrackingFilterController<F extends TrackingFilter>
    extends Notifier<F> {
  /// The filter with nothing narrowed — what the list shows on first open.
  F get pristine;

  @override
  F build() => pristine;

  /// Narrows [state] and keeps the concrete filter type.
  ///
  /// Every subclass overrides `copyWith` to return its own type, so this cast
  /// always holds; Dart simply has no way to say "returns my own type" in the
  /// base class signature.
  F _narrowed(TrackingFilter next) => next as F;

  void setQuery(String value) => state = _narrowed(
    value.trim().isEmpty
        ? state.copyWith(clearQuery: true)
        : state.copyWith(query: value),
  );

  void setMinRating(double? value) => state = _narrowed(
    value == null
        ? state.copyWith(clearMinRating: true)
        : state.copyWith(minRating: value),
  );

  void setSort(TrackingSort sort) =>
      state = _narrowed(state.copyWith(sort: sort));

  /// Drops every narrowing but keeps the ordering: clearing a search should
  /// not silently reshuffle the list under the owner's eyes.
  void clear() => state = _narrowed(pristine.copyWith(sort: state.sort));
}
