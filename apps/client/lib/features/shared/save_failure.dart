import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Runs [save] and tells the owner when it throws; returns whether it held.
///
/// A form's Save has no one else waiting on its future: an error there goes
/// to the zone, and the owner is left with a form that neither closes nor
/// says anything — or, worse, believing the entry was kept. This turns that
/// into a message they can act on, and still reports the error to the log.
Future<bool> guardSave(
  BuildContext context,
  Future<void> Function() save,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final message = AppLocalizations.of(context).saveFailed;
  try {
    await save();
    return true;
  } on Object catch (error, stack) {
    developer.log(
      'Saving an entry failed',
      name: 'memini',
      error: error,
      stackTrace: stack,
    );
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
    return false;
  }
}
