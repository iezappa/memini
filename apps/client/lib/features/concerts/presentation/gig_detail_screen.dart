import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/tracker_detail.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';
import '../domain/gig.dart';
import 'gig_form_screen.dart';
import 'gig_providers.dart';

class GigDetailScreen extends ConsumerWidget {
  const GigDetailScreen({super.key, required this.gigId});

  final int gigId;

  Future<void> _edit(BuildContext context, Gig gig) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => GigFormScreen(gig: gig)));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Gig gig) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteGig,
      body: l10n.deleteGigConfirm,
    );
    if (!confirmed) return;

    await ref.read(gigRepositoryProvider).delete(gig.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gig = ref.watch(gigProvider(gigId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (gig.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, gig.value!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, gig.value!),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: gig.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.retry,
            body: '$error',
          ),
          data: (value) {
            if (value == null) {
              return EmptyState(
                icon: Icons.music_note_outlined,
                title: l10n.gigEmptyTitle,
              );
            }
            return TrackerDetailBody(
              title: value.title,
              happenedOn: value.happenedOn,
              rating: value.rating,
              photoPath: value.photoPath,
              placeholderIcon: Icons.music_note_outlined,
              contextLine: [?value.venue, ?value.city].join(', ').ifEmptyNull(),
              description: value.description,
              review: value.review,
              facts: [
                if (value.supportActs != null)
                  (label: l10n.fieldSupportActs, value: value.supportActs!),
                if (value.company != null)
                  (label: l10n.fieldCompany, value: value.company!),
              ],
              extra: [
                if (value.setlist != null) ...[
                  Gap.vXl,
                  SectionLabel(l10n.fieldSetlist),
                  Gap.vSm,
                  // One song per line, numbered so a long set stays readable.
                  for (final (index, song)
                      in value.setlist!.split('\n').indexed)
                    if (song.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Gap.xs),
                        child: Text(
                          '${index + 1}. ${song.trim()}',
                          style: context.text.bodyLarge,
                        ),
                      ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

extension on String {
  /// Joining optional parts can leave an empty string; the detail header
  /// wants null in that case so it does not render a stray separator.
  String? ifEmptyNull() => isEmpty ? null : this;
}
