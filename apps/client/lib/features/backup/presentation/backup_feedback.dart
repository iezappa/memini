import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import 'backup_actions.dart';

/// Exports the full backup and says how it went.
///
/// Shared by every place that offers an export, so the banner, the erase
/// dialog and settings cannot describe the same outcome in different words.
Future<bool> exportBackupWithFeedback(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final saved = await ref.read(backupActionsProvider).exportBackup();

  // The previous message is about a run that already finished; leaving it
  // queued would show stale news before the news that was asked for.
  messenger
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(saved ? l10n.exportDone : l10n.exportFailed)),
    );
  return saved;
}
