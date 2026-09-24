import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../domain/entry_photo.dart';
import 'photo_providers.dart';

/// The pictures the owner took of one entry, with a way to add another.
///
/// A row that scrolls rather than a grid: most entries have one photo and
/// a grid of one is a lot of empty boxes. Shown from the bytes in the
/// store, so it looks the same on a phone, a desktop and a browser tab —
/// which the old path-based version could not manage.
class PhotoStrip extends ConsumerWidget {
  const PhotoStrip({required this.ownerId, super.key});

  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final photos = ref.watch(photosProvider(ownerId)).valueOrNull ?? const [];
    final actions = ref.read(photoActionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final photo in photos)
                Padding(
                  padding: const EdgeInsets.only(right: Gap.sm),
                  child: _Thumbnail(
                    photo: photo,
                    onRemove: () => _confirmRemove(context, ref, photo.id),
                  ),
                ),
              _AddButton(onPressed: () => actions.attach(ownerId)),
            ],
          ),
        ),
        if (photos.isEmpty) ...[
          Gap.vXs,
          Text(
            l10n.photosEmpty,
            style: context.text.bodySmall?.copyWith(
              color: context.semantics.muted,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.photosRemoveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.photosRemove),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await ref.read(photoActionsProvider).remove(id);
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photo, required this.onRemove});

  final EntryPhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: Radii.field,
          child: Image.memory(
            photo.bytes,
            width: 160,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: l10n.photosRemove,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.45),
              foregroundColor: Colors.white,
            ),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 120,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, size: 20),
            Gap.vXs,
            Text(
              l10n.photosAdd,
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
