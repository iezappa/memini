import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../backup/presentation/backup_feedback.dart';
import '../../legal/presentation/legal_links.dart';
import 'update_providers.dart';

/// "A new version is available", docked under the open tab (§8.2).
///
/// Checked at launch and again whenever the app comes back to the
/// foreground. Dismissing hides it until the next version.
class UpdateBanner extends ConsumerStatefulWidget {
  const UpdateBanner({super.key});

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(availableUpdateProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(availableUpdateProvider).valueOrNull;
    final current = ref.watch(runningVersionProvider).valueOrNull;
    if (info == null) return const SizedBox.shrink();

    final min = info.minSupportedVersion;
    final unsupported = min != null && current != null && current < min;

    return MaterialBanner(
      leading: const Icon(Icons.system_update_outlined),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.updateAvailableTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(l10n.updateAvailableBody('${info.latest}')),
          if (info.schemaChange) Text(l10n.updateAvailableBackupHint),
          if (unsupported) Text(l10n.updateUnsupportedPath),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await ref
                .read(settingsRepositoryProvider)
                .setDismissedUpdateVersion('${info.latest}');
            ref.invalidate(availableUpdateProvider);
          },
          child: Text(l10n.updateActionDismiss),
        ),
        if (info.schemaChange || unsupported)
          OutlinedButton(
            onPressed: () => exportBackupWithFeedback(context, ref),
            child: Text(l10n.updateActionExport),
          ),
        FilledButton.tonal(
          onPressed: () => kIsWeb
              ? ref.read(serviceWorkerBridgeProvider).applyUpdate()
              : ref.read(urlOpenerProvider)(info.url),
          child: Text(
            kIsWeb ? l10n.updateActionReload : l10n.updateActionDownload,
          ),
        ),
      ],
    );
  }
}
