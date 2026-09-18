import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Runs [save] and tells the owner when it throws; returns whether it held.
///
/// A form's Save has no one else waiting on its future: an error there goes
/// to the zone, and the owner is left with a form that neither closes nor
/// says anything — or, worse, believing the entry was kept. This turns that
/// into a message they can act on, and still reports the error to the log.
Future<bool> guardSave(BuildContext context, Future<void> Function() save) =>
    _guardWrite(
      context,
      save,
      message: AppLocalizations.of(context).saveFailed,
      log: 'Saving an entry failed',
    );

/// Runs [delete] and tells the owner when it throws; returns whether it held.
///
/// Without it a refused delete leaves the entry in place with nothing on
/// screen to say so, and the owner walks away believing it is gone.
Future<bool> guardDelete(
  BuildContext context,
  Future<void> Function() delete,
) => _guardWrite(
  context,
  delete,
  message: AppLocalizations.of(context).deleteFailed,
  log: 'Deleting an entry failed',
);

Future<bool> _guardWrite(
  BuildContext context,
  Future<void> Function() write, {
  required String message,
  required String log,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    await write();
    return true;
  } on Object catch (error, stack) {
    developer.log(log, name: 'memini', error: error, stackTrace: stack);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
    return false;
  }
}
