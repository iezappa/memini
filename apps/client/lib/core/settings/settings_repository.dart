import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/tokens.dart';

/// Every user preference that is not domain data, in one place.
///
/// Backed by shared_preferences because none of it is sensitive and all of it
/// must survive a restart. The PIN itself lives in secure storage instead.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _localeKey = 'settings.locale';
  static const _themeKey = 'settings.theme_mode';
  static const _tutorialKey = 'onboarding.tutorial_seen';
  static const _disclaimerKey = 'onboarding.disclaimer_accepted';
  static const _displayNameKey = 'profile.display_name';
  static const _accentKey = 'settings.accent';
  static const _backupNoticeKey = 'onboarding.backup_notice_accepted';
  static const _lastExportKey = 'backup.last_export_at';
  static const _reminderDismissedKey = 'backup.reminder_dismissed_at';
  static const _lastSeenVersionKey = 'releaseNotes.lastSeenVersion';

  /// Preferences that survive "delete all my data".
  ///
  /// How the app looks and which language it speaks. None of it says anything
  /// about the person, and losing it would greet them — right after they
  /// deleted everything — in a language they may not read.
  static const keptOnErase = {_localeKey, _themeKey, _accentKey};

  /// Lookup keys are the owner's own: TMDB and RAWG both issue them free for
  /// personal use, and neither licence lets an app ship one for everybody.
  static const _tmdbKeyKey = 'enrichment.tmdb_api_key';
  static const _rawgKeyKey = 'enrichment.rawg_api_key';

  /// Null means "follow the system language".
  Locale? get locale {
    final code = _prefs.getString(_localeKey);
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? value) async {
    if (value == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, value.languageCode);
    }
  }

  ThemeMode get themeMode {
    return switch (_prefs.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode value) =>
      _prefs.setString(_themeKey, value.name);

  /// Falls back to brass for anything unrecognised, so an accent renamed or
  /// dropped in a later version cannot leave the app without a primary.
  AppAccent get accent {
    final name = _prefs.getString(_accentKey);
    return AppAccent.values.firstWhere(
      (accent) => accent.name == name,
      orElse: () => AppAccent.brass,
    );
  }

  Future<void> setAccent(AppAccent value) =>
      _prefs.setString(_accentKey, value.name);

  bool get tutorialSeen => _prefs.getBool(_tutorialKey) ?? false;

  Future<void> markTutorialSeen() => _prefs.setBool(_tutorialKey, true);

  bool get disclaimerAccepted => _prefs.getBool(_disclaimerKey) ?? false;

  Future<void> acceptDisclaimer() => _prefs.setBool(_disclaimerKey, true);

  /// Whether the owner accepted that their data lives only on this device.
  ///
  /// Separate from the disclaimer on purpose: everyone onboarded before the
  /// notice existed has that flag and not this one, which is exactly what
  /// shows them the notice once.
  bool get backupNoticeAccepted => _prefs.getBool(_backupNoticeKey) ?? false;

  Future<void> acceptBackupNotice() => _prefs.setBool(_backupNoticeKey, true);

  /// Kept in preferences rather than the database: the database is what the
  /// backup carries, and a restore must not bring back the date of an export
  /// made on another device.
  DateTime? get lastExportAt => _dateAt(_lastExportKey);

  Future<void> recordExport(DateTime at) =>
      _prefs.setString(_lastExportKey, at.toIso8601String());

  DateTime? get backupReminderDismissedAt => _dateAt(_reminderDismissedKey);

  Future<void> snoozeBackupReminder(DateTime at) =>
      _prefs.setString(_reminderDismissedKey, at.toIso8601String());

  /// The newest version whose release notes this device has been shown.
  String? get lastSeenVersion => _prefs.getString(_lastSeenVersionKey);

  Future<void> setLastSeenVersion(String version) =>
      _prefs.setString(_lastSeenVersionKey, version);

  /// Forgets every preference except [keptOnErase].
  Future<void> eraseAllButAppearance() async {
    for (final key in _prefs.getKeys().difference(keptOnErase)) {
      await _prefs.remove(key);
    }
  }

  DateTime? _dateAt(String key) {
    final stored = _prefs.getString(key);
    return stored == null ? null : DateTime.tryParse(stored);
  }

  String? get displayName => _prefs.getString(_displayNameKey);

  Future<void> setDisplayName(String? value) async {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _prefs.remove(_displayNameKey);
    } else {
      await _prefs.setString(_displayNameKey, trimmed);
    }
  }

  String? get tmdbApiKey => _nonBlank(_prefs.getString(_tmdbKeyKey));

  Future<void> setTmdbApiKey(String? value) => _writeKey(_tmdbKeyKey, value);

  String? get rawgApiKey => _nonBlank(_prefs.getString(_rawgKeyKey));

  Future<void> setRawgApiKey(String? value) => _writeKey(_rawgKeyKey, value);

  /// A blank key is the same as no key: it would only produce 401s.
  static String? _nonBlank(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Future<void> _writeKey(String key, String? value) async {
    final trimmed = _nonBlank(value);
    if (trimmed == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, trimmed);
    }
  }
}
