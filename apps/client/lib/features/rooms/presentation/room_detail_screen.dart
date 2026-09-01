import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';
import '../domain/room.dart';
import 'room_form_screen.dart';

class RoomDetailScreen extends ConsumerWidget {
  const RoomDetailScreen({super.key, required this.roomId});

  final int roomId;

  Future<void> _edit(BuildContext context, WidgetRef ref, Room room) async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => RoomFormScreen(room: room)));
    ref.invalidate(roomProvider(roomId));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Room room) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoom),
        content: Text(l10n.deleteRoomConfirm(room.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(roomRepositoryProvider).delete(room.id);
    await ref.read(photoStorageProvider).remove(room.photoPath);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final room = ref.watch(roomProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (room.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editRoom,
              onPressed: () => _edit(context, ref, room.value!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteRoom,
              onPressed: () => _delete(context, ref, room.value!),
            ),
            Gap.hSm,
          ],
        ],
      ),
      body: SafeArea(
        child: room.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.retry,
            body: '$error',
          ),
          data: (value) {
            if (value == null) {
              return EmptyState(
                icon: Icons.help_outline,
                title: l10n.emptyFiltered,
              );
            }
            return _RoomBody(room: value);
          },
        ),
      ),
    );
  }
}

class _RoomBody extends ConsumerWidget {
  const _RoomBody({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final franchises = ref.watch(franchisesProvider).valueOrNull ?? const [];
    final franchiseName = franchises
        .where((f) => f.id == room.franchiseId)
        .map((f) => f.name)
        .firstOrNull;

    return ContentColumn(
      child: ListView(
        padding: const EdgeInsets.only(bottom: Gap.xl),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: EntryPhoto(path: room.photoPath, width: double.infinity),
          ),
          Gap.vLg,
          Text(room.title, style: context.text.displaySmall),
          Gap.vXs,
          Text(
            [
              ?franchiseName,
              DateFormat.yMMMMd(locale).format(room.happenedOn),
            ].join(' · '),
            style: context.text.bodySmall,
          ),
          Gap.vMd,
          Row(
            children: [
              ScoreBadge(rating: room.rating, large: true),
              Gap.hMd,
              OutcomePill(
                escaped: room.escaped,
                timeLeftMinutes: room.timeLeftMinutes,
              ),
            ],
          ),
          if (room.description != null) ...[
            Gap.vXl,
            SectionLabel(l10n.fieldDescription),
            Gap.vSm,
            Text(room.description!, style: context.text.bodyLarge),
          ],
          if (room.review != null) ...[
            Gap.vXl,
            SectionLabel(l10n.fieldReview),
            Gap.vSm,
            Text(room.review!, style: context.text.bodyLarge),
          ],
        ],
      ),
    );
  }
}
