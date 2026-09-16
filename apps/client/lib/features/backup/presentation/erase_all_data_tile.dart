import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import 'backup_actions.dart';
import 'backup_feedback.dart';

/// "Delete all my data", the last row of Your data.
class EraseAllDataTile extends StatelessWidget {
  const EraseAllDataTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = context.colors.error;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.delete_forever_outlined, color: error),
      title: Text(l10n.eraseAllData, style: TextStyle(color: error)),
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => const _EraseAllDataDialog(),
      ),
    );
  }
}

/// Asks for a typed word, not just a tap.
///
/// A second button in the same place is a confirmation a thumb gets through
/// by accident. Typing a word cannot be done without reading the dialog, and
/// this is the one action in the app with no way back.
class _EraseAllDataDialog extends ConsumerStatefulWidget {
  const _EraseAllDataDialog();

  @override
  ConsumerState<_EraseAllDataDialog> createState() =>
      _EraseAllDataDialogState();
}

class _EraseAllDataDialogState extends ConsumerState<_EraseAllDataDialog> {
  final _typed = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  Future<void> _exportFirst() async {
    setState(() => _busy = true);
    try {
      await exportBackupWithFeedback(context, ref);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _erase() async {
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    try {
      await ref.read(eraseAllDataActionsProvider).eraseEverything();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final word = l10n.eraseAllConfirmWord;
    final confirmed = _typed.text.trim().toUpperCase() == word;

    return AlertDialog(
      title: Text(l10n.eraseAllTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.eraseAllBody),
            Gap.vLg,
            TextField(
              controller: _typed,
              enabled: !_busy,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.eraseAllTypeToConfirm(word),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        OutlinedButton(
          onPressed: _busy ? null : _exportFirst,
          child: Text(l10n.eraseAllExportFirst),
        ),
        FilledButton(
          onPressed: _busy || !confirmed ? null : _erase,
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.onError,
          ),
          child: Text(l10n.eraseAllAction),
        ),
      ],
    );
  }
}
