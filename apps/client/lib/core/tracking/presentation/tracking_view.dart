import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// The two shapes a tracked list can take.
///
/// A list reads a hundred entries at a glance and a grid shows what they
/// looked like; which one is right depends on the domain and on the mood, so
/// the owner picks and the app remembers.
enum TrackerView { list, grid }

/// Remembered across launches and shared by all five domains: a person who
/// wants covers wants them everywhere, and setting it five times would be
/// five ways to be inconsistent.
class TrackerViewController extends Notifier<TrackerView> {
  static const _key = 'tracking.view';

  @override
  TrackerView build() {
    final stored = ref.watch(sharedPreferencesProvider).getString(_key);

    return TrackerView.values.firstWhere(
      (view) => view.name == stored,
      orElse: () => TrackerView.list,
    );
  }

  void set(TrackerView view) {
    state = view;
    ref.read(sharedPreferencesProvider).setString(_key, view.name);
  }
}

final trackerViewProvider =
    NotifierProvider<TrackerViewController, TrackerView>(
      TrackerViewController.new,
    );

/// How many entries fill one page.
///
/// Enough that scrolling is still the normal way to move through a page, few
/// enough that a grid of covers does not ask the browser to decode a hundred
/// pictures at once.
const kEntriesPerPage = 24;
