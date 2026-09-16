import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';

/// Shows the backup notice once to someone onboarded before it existed.
///
/// Sits inside the router, where a navigator exists to open the dialog on.
/// A first run never gets here without the notice: onboarding asks for it on
/// its last page.
class BackupNoticeCheck extends ConsumerStatefulWidget {
  const BackupNoticeCheck({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<BackupNoticeCheck> createState() => _BackupNoticeCheckState();
}

class _BackupNoticeCheckState extends ConsumerState<BackupNoticeCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(settingsRepositoryProvider).backupNoticeAccepted) return;
      showBackupNoticeDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Shown once and only closed by accepting it: the whole point is that nobody
/// keeps using the app without having been told that no copy of their data
/// exists anywhere else.
Future<void> showBackupNoticeDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) => const _BackupNoticeDialog(),
);

class _BackupNoticeDialog extends ConsumerWidget {
  const _BackupNoticeDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        icon: const Icon(Icons.phone_android_outlined),
        title: Text(l10n.backupNoticeTitle),
        content: SizedBox(width: 420, child: Text(l10n.backupNoticeBody)),
        actions: [
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ref.read(settingsRepositoryProvider).acceptBackupNotice();
              navigator.pop();
            },
            child: Text(l10n.backupNoticeAccept),
          ),
        ],
      ),
    );
  }
}
