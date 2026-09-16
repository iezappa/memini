import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/app/app_restart.dart';
import '../../../core/database/local_store.dart';
import '../../../core/time/clock.dart';
import '../data/backup_service.dart';
import '../domain/backup_document.dart';
import '../domain/backup_reminder.dart';
import 'backup_files.dart';

export 'backup_files.dart';

/// How an import from a file ended.
enum RestoreOutcome {
  /// The user backed out of the picker.
  cancelled,

  /// The file is not a backup this build can read; nothing was touched.
  rejected,

  restored,

  /// The file was valid but writing it failed.
  failed,
}

/// How a full export ended.
class ExportResult {
  const ExportResult({required this.saved, this.missingPhotos = 0});

  const ExportResult.failed() : saved = false, missingPhotos = 0;

  final bool saved;

  /// Photos whose file was gone, left out of an export that still succeeded.
  final int missingPhotos;
}

/// Export entry points shared by every place that offers one, so an export
/// from a banner and one from settings cannot drift apart.
class BackupActions {
  BackupActions(this._ref);

  final Ref _ref;

  static String _stamp(DateTime now) => now.toIso8601String().split('T').first;

  /// The full backup, as one zip with the photos inside.
  Future<ExportResult> exportBackup() async {
    try {
      final export = await _ref.read(backupServiceProvider).exportArchive();
      final now = _ref.read(clockProvider)();
      final saved = await _ref.read(backupFilesProvider).save({
        'memini-backup-${_stamp(now)}.zip': export.bytes,
      });
      if (!saved) return const ExportResult.failed();

      // Only the full backup counts: a CSV cannot be imported back.
      await _ref.read(settingsRepositoryProvider).recordExport(now);
      _ref.invalidate(backupReminderProvider);
      return ExportResult(saved: true, missingPhotos: export.missingPhotos);
    } on Object {
      return const ExportResult.failed();
    }
  }

  /// One CSV sheet per domain: five shapes cannot share a header without
  /// inventing empty columns.
  Future<bool> exportCsv() async {
    try {
      final sheets = await _ref.read(backupServiceProvider).exportCsv();
      final stamp = _stamp(DateTime.now());
      return await _ref.read(backupFilesProvider).save({
        for (final entry in sheets.entries)
          'memini-${entry.key}-$stamp.csv': Uint8List.fromList(
            utf8.encode(entry.value),
          ),
      });
    } on Object {
      return false;
    }
  }
}

final backupActionsProvider = Provider<BackupActions>(BackupActions.new);

/// The way out of a store that cannot be opened.
///
/// Neither option tries to repair the store in place: a database that fails
/// to open has already shown it cannot be trusted, and a repair that guesses
/// wrong looks exactly like one that worked. Both start from empty, both are
/// asked for explicitly, and both end by starting the app again.
class DatabaseRecoveryActions {
  DatabaseRecoveryActions(this._ref);

  final Ref _ref;

  /// Deletes the store and starts the app over, empty.
  Future<void> reset() async {
    await _eraseStore();
    _ref.read(restartAppProvider)();
  }

  /// Puts a backup file where the broken store was.
  ///
  /// The file is read and checked before anything is deleted, so picking the
  /// wrong one — or backing out — leaves the device exactly as it was.
  Future<RestoreOutcome> importBackup() async {
    final bytes = await _ref.read(backupFilesProvider).open();
    if (bytes == null) return RestoreOutcome.cancelled;

    final ParsedBackup backup;
    try {
      backup = BackupService.parseFile(bytes);
    } on BackupFormatException {
      return RestoreOutcome.rejected;
    }

    try {
      await _eraseStore();
      // A connection that failed to open stays failed, so the restore needs
      // a new one on the new, empty store.
      _ref.invalidate(databaseProvider);
      await _ref.read(backupServiceProvider).restoreParsed(backup);
      _ref.read(restartAppProvider)();
      return RestoreOutcome.restored;
    } on Object {
      return RestoreOutcome.failed;
    }
  }

  Future<void> _eraseStore() async {
    try {
      await _ref.read(databaseProvider).close();
    } on Object {
      // Closing a connection that never opened can fail too. The storage is
      // about to be deleted either way.
    }
    await _ref.read(eraseLocalStoreProvider)();
  }
}

final databaseRecoveryActionsProvider = Provider<DatabaseRecoveryActions>(
  DatabaseRecoveryActions.new,
);

/// Whether to nudge the owner to export, decided once per launch.
final backupReminderProvider = FutureProvider<BackupReminder>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);

  return backupReminderFor(
    now: ref.watch(clockProvider)(),
    lastExportAt: settings.lastExportAt,
    dismissedAt: settings.backupReminderDismissedAt,
    holdsData: await ref.watch(backupServiceProvider).holdsUserData(),
  );
});

/// "Delete all my data": the store, the photos, the PIN, the preferences, and
/// back to the start.
class EraseAllDataActions {
  EraseAllDataActions(this._ref);

  final Ref _ref;

  Future<void> eraseEverything() async {
    await _ref.read(backupServiceProvider).eraseEverything();
    await _ref.read(photoStorageProvider).removeAll();
    await _ref.read(pinServiceProvider).clear();
    await _ref.read(settingsRepositoryProvider).eraseAllButAppearance();

    // Onboarding is gone with the rest, so the restart lands on it.
    _ref.read(restartAppProvider)();
  }
}

final eraseAllDataActionsProvider = Provider<EraseAllDataActions>(
  EraseAllDataActions.new,
);
