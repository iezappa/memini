import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/app_database.dart';
import '../core/settings/settings_repository.dart';
import '../core/tracking/presentation/tracking_filter_controller.dart';
import '../features/backup/data/backup_service.dart';
import '../features/franchises/data/drift_franchise_repository.dart';
import '../features/franchises/domain/franchise.dart';
import '../features/franchises/domain/franchise_repository.dart';
import '../features/rooms/data/drift_room_repository.dart';
import '../features/rooms/domain/room.dart';
import '../features/rooms/domain/room_repository.dart';
import '../features/security/data/pin_service.dart';
import '../features/shared/photo_storage.dart';
import '../features/stats/domain/room_stats.dart';

/// Overridden in main() once the async singletons are ready, so no widget
/// ever has to unwrap a FutureProvider just to read a preference.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => DriftRoomRepository(ref.watch(databaseProvider)),
);

final franchiseRepositoryProvider = Provider<FranchiseRepository>(
  (ref) => DriftFranchiseRepository(ref.watch(databaseProvider)),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

final pinServiceProvider = Provider<PinService>(
  (ref) => PinService(const FlutterSecureStore()),
);

final photoStorageProvider = Provider<PhotoStorage>(
  (ref) => const PhotoStorage(),
);

/// The live filter of the collection screen.
final roomFilterProvider = NotifierProvider<RoomFilterController, RoomFilter>(
  RoomFilterController.new,
);

class RoomFilterController extends TrackingFilterController<RoomFilter> {
  @override
  RoomFilter get pristine => const RoomFilter();

  void setFranchise(int? id) => state = id == null
      ? state.copyWith(clearFranchise: true)
      : state.copyWith(franchiseId: id);

  void setEscaped(bool? value) => state = value == null
      ? state.copyWith(clearEscaped: true)
      : state.copyWith(escaped: value);
}

/// The filtered collection, kept live by Drift's own table watching.
final roomsProvider = StreamProvider<List<Room>>((ref) {
  final filter = ref.watch(roomFilterProvider);
  return ref.watch(roomRepositoryProvider).watch(filter);
});

/// Every room, unfiltered — stats describe the whole record, not the view.
final allRoomsProvider = StreamProvider<List<Room>>(
  (ref) => ref.watch(roomRepositoryProvider).watch(const RoomFilter()),
);

final statsProvider = Provider<AsyncValue<RoomStats>>((ref) {
  return ref.watch(allRoomsProvider).whenData(RoomStats.from);
});

final franchisesProvider = StreamProvider<List<Franchise>>(
  (ref) => ref.watch(franchiseRepositoryProvider).watchAll(),
);

/// Franchise names by id, so a list can label every row without the
/// repository having to join. The franchise list is small and already live.
final franchiseNamesProvider = Provider<Map<int, String>>((ref) {
  final franchises = ref.watch(franchisesProvider).valueOrNull ?? const [];
  return {for (final franchise in franchises) franchise.id: franchise.name};
});

final roomProvider = FutureProvider.family<Room?, int>((ref, id) {
  // Re-resolves whenever the collection changes so an edit is reflected
  // without the detail screen having to invalidate itself.
  ref.watch(allRoomsProvider);
  return ref.watch(roomRepositoryProvider).findById(id);
});

/// App-wide preferences, exposed as state so a change repaints immediately.
final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => ref.watch(settingsRepositoryProvider).locale;

  Future<void> set(Locale? value) async {
    await ref.read(settingsRepositoryProvider).setLocale(value);
    state = value;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(settingsRepositoryProvider).themeMode;

  Future<void> set(ThemeMode value) async {
    await ref.read(settingsRepositoryProvider).setThemeMode(value);
    state = value;
  }
}

final accentProvider = NotifierProvider<AccentController, AppAccent>(
  AccentController.new,
);

class AccentController extends Notifier<AppAccent> {
  @override
  AppAccent build() => ref.watch(settingsRepositoryProvider).accent;

  Future<void> set(AppAccent value) async {
    await ref.read(settingsRepositoryProvider).setAccent(value);
    state = value;
  }
}

final displayNameProvider = NotifierProvider<DisplayNameController, String?>(
  DisplayNameController.new,
);

class DisplayNameController extends Notifier<String?> {
  @override
  String? build() => ref.watch(settingsRepositoryProvider).displayName;

  Future<void> set(String? value) async {
    await ref.read(settingsRepositoryProvider).setDisplayName(value);
    state = ref.read(settingsRepositoryProvider).displayName;
  }
}

/// Whether the first-run flow (tutorial + disclaimer) still has to be shown.
final onboardingDoneProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() {
    final settings = ref.watch(settingsRepositoryProvider);
    return settings.tutorialSeen && settings.disclaimerAccepted;
  }

  Future<void> complete() async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.markTutorialSeen();
    await settings.acceptDisclaimer();
    state = true;
  }
}

final pinEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(pinServiceProvider).isEnabled,
);

/// False until the PIN screen has been cleared for this app session.
final unlockedProvider = NotifierProvider<UnlockController, bool>(
  UnlockController.new,
);

class UnlockController extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;
}

/// The owner's own lookup keys, exposed as state so entering one in Settings
/// immediately enables the lookup button in the forms.
final tmdbApiKeyProvider = NotifierProvider<TmdbApiKeyController, String?>(
  TmdbApiKeyController.new,
);

class TmdbApiKeyController extends Notifier<String?> {
  @override
  String? build() => ref.watch(settingsRepositoryProvider).tmdbApiKey;

  Future<void> set(String? value) async {
    await ref.read(settingsRepositoryProvider).setTmdbApiKey(value);
    state = ref.read(settingsRepositoryProvider).tmdbApiKey;
  }
}

final rawgApiKeyProvider = NotifierProvider<RawgApiKeyController, String?>(
  RawgApiKeyController.new,
);

class RawgApiKeyController extends Notifier<String?> {
  @override
  String? build() => ref.watch(settingsRepositoryProvider).rawgApiKey;

  Future<void> set(String? value) async {
    await ref.read(settingsRepositoryProvider).setRawgApiKey(value);
    state = ref.read(settingsRepositoryProvider).rawgApiKey;
  }
}
