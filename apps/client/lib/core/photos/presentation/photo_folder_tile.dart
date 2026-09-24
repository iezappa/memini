import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../domain/photo_folder.dart';
import 'photo_folder_providers.dart';

/// The folder photographs are copied into, as a settings row.
///
/// It sits in the data section beside export and import for a reason: this
/// is the backup story for pictures, which are the one thing the backup file
/// deliberately leaves out.
class PhotoFolderTile extends ConsumerWidget {
  const PhotoFolderTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final supported = ref.watch(photoFolderProvider).isSupported;
    final status = ref.watch(photoFolderStatusProvider).valueOrNull;
    final controller = ref.read(photoFolderStatusProvider.notifier);

    final problem = status?.problem;
    final subtitle = switch (problem) {
      PhotoFolderProblem.folderGone => l10n.photoFolderGone,
      PhotoFolderProblem.needsPermission => l10n.photoFolderNeedsPermission,
      PhotoFolderProblem.failed => l10n.photoFolderFailed,
      null when !supported => l10n.photoFolderUnsupported,
      null when status?.name != null => l10n.photoFolderOn(status!.name!),
      null => l10n.photoFolderOff,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.folder_copy_outlined),
          title: Text(l10n.photoFolderTitle),
          subtitle: Text(
            subtitle,
            style: context.text.bodySmall?.copyWith(
              color: problem == null
                  ? context.semantics.muted
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          trailing: supported
              ? TextButton(
                  onPressed: controller.choose,
                  child: Text(
                    status?.name == null
                        ? l10n.photoFolderChoose
                        : l10n.photoFolderChange,
                  ),
                )
              : null,
        ),
        if (supported && status?.name != null)
          Padding(
            // Lined up under the title rather than the icon, so the two
            // follow-up actions read as belonging to the row above them.
            padding: const EdgeInsets.only(left: Gap.xl + Gap.md),
            child: OverflowBar(
              spacing: Gap.sm,
              children: [
                TextButton(
                  onPressed: controller.copyEverything,
                  child: Text(l10n.photoFolderCopyAll),
                ),
                TextButton(
                  onPressed: controller.forget,
                  child: Text(l10n.photoFolderStop),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
