import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tracking/presentation/tracker_detail.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';
import '../domain/viewing.dart';
import 'viewing_form_screen.dart';
import 'viewing_labels.dart';
import 'viewing_providers.dart';

class ViewingDetailScreen extends ConsumerWidget {
  const ViewingDetailScreen({super.key, required this.viewingId});

  final int viewingId;

  Future<void> _edit(BuildContext context, Viewing viewing) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ViewingFormScreen(viewing: viewing),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Viewing viewing,
  ) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteViewing,
      body: l10n.deleteConfirm(viewing.title),
    );
    if (!confirmed) return;

    await ref.read(viewingRepositoryProvider).delete(viewing.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final viewing = ref.watch(viewingProvider(viewingId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (viewing.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, viewing.value!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, viewing.value!),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: viewing.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.retry,
            body: '$error',
          ),
          data: (value) {
            if (value == null) {
              return EmptyState(
                icon: Icons.movie_outlined,
                title: l10n.viewingEmptyTitle,
              );
            }
            return TrackerDetailBody(
              title: value.title,
              happenedOn: value.happenedOn,
              rating: value.rating,
              photoPath: value.photoPath,
              placeholderIcon: Icons.movie_outlined,
              contextLine: value.releaseYear?.toString(),
              badge: Text(viewingKindLabel(l10n, value.kind)),
              description: value.description,
              review: value.review,
              facts: [
                if (value.season != null)
                  (
                    label: l10n.fieldSeason,
                    value: l10n.seasonValue(value.season!),
                  ),
                if (value.director != null)
                  (label: l10n.fieldDirector, value: value.director!),
                if (value.cast != null)
                  (label: l10n.fieldCast, value: value.cast!),
              ],
            );
          },
        ),
      ),
    );
  }
}
