import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/app/app_restart.dart';
import '../../../core/database/local_store.dart';
import '../data/backup_service.dart';
import '../domain/backup_document.dart';
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

/// Export entry points shared by every place that offers one, so an export
/// from a banner and one from settings cannot drift apart.
class BackupActions {
  BackupActions(this._ref);

  final Ref _ref;

  static String _stamp(DateTime now) => now.toIso8601String().split('T').first;

  /// The full backup. False when the file could not be handed over.
  Future<bool> exportBackup() async {
    try {
      final json = await _ref.read(backupServiceProvider).exportJson();
      return await _ref.read(backupFilesProvider).save({
        'memini-backup-${_stamp(DateTime.now())}.json': utf8.encode(json),
      });
    } on Object {
      return false;
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

    final BackupDocument document;
    try {
      document = BackupService.parse(utf8.decode(bytes));
    } on BackupFormatException {
      return RestoreOutcome.rejected;
    } on FormatException {
      return RestoreOutcome.rejected;
    }

    try {
      await _eraseStore();
      // A connection that failed to open stays failed, so the restore needs
      // a new one on the new, empty store.
      _ref.invalidate(databaseProvider);
      await _ref.read(backupServiceProvider).restore(document);
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
