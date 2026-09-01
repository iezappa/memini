import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The device-local key/value store, resolved once at startup.
///
/// Overridden in [main] with the instance obtained before the first frame, so
/// the rest of the app can read preferences synchronously — no Future threaded
/// through the UI, no spinner just to paint the right theme.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before use',
  ),
);

/// A single remembered boolean, such as whether the tutorial has been seen.
///
/// Writes are fire-and-forget: losing one to a crash costs nothing, and the UI
/// must never wait on a disk write to open a card.
class BoolPreference extends StateNotifier<bool> {
  BoolPreference(this._prefs, this._key, {required bool fallback})
    : super(_prefs.getBool(_key) ?? fallback);

  final SharedPreferences _prefs;
  final String _key;

  void set(bool value) {
    state = value;
    _prefs.setBool(_key, value);
  }

  void toggle() => set(!state);
}

/// A single remembered string, such as the chosen accent.
class StringPreference extends StateNotifier<String> {
  StringPreference(this._prefs, this._key, {required String fallback})
    : super(_prefs.getString(_key) ?? fallback);

  final SharedPreferences _prefs;
  final String _key;

  void set(String value) {
    state = value;
    _prefs.setString(_key, value);
  }

  /// Clears the stored value and falls back to what the declaration named.
  void reset() {
    state = _fallback;
    _prefs.remove(_key);
  }

  String get _fallback => _prefs.getString(_key) ?? state;
}

/// A remembered set of identifiers, such as which destinations stay visible.
class StringSetPreference extends StateNotifier<Set<String>> {
  StringSetPreference(this._prefs, this._key, {required Set<String> fallback})
    : _fallback = fallback,
      super(_repair(_prefs.getStringList(_key)?.toSet(), fallback));

  final SharedPreferences _prefs;
  final String _key;
  final Set<String> _fallback;

  /// A stored value written by an older build, hand-edited or truncated must
  /// not break startup — an empty set is repaired on read, not trusted.
  static Set<String> _repair(Set<String>? stored, Set<String> fallback) =>
      (stored == null || stored.isEmpty) ? fallback : stored;

  void set(Set<String> value) {
    final repaired = _repair(value, _fallback);
    state = repaired;
    _prefs.setStringList(_key, repaired.toList());
  }
}
