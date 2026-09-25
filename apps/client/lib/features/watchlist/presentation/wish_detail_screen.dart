import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/domain/tracked_domain.dart';
import '../../../core/tracking/presentation/tracker_detail.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/entry_dialog.dart';
import '../../shared/entry_screens.dart';
import '../../shared/save_failure.dart';
import '../../shared/widgets.dart';
import '../domain/wish.dart';
import 'wish_form_screen.dart';
import 'wish_fulfilment.dart';
import 'wish_labels.dart';
import 'wish_providers.dart';

/// One thing on the watchlist, with the two things you can do to it: put it
/// away because you have seen it, or take it off because you never will.
class WishDetailScreen extends ConsumerWidget {
  const WishDetailScreen({super.key, required this.wishId});

  final String wishId;

  Future<void> _edit(BuildContext context, Wish wish) =>
      showEntryDialog(context, WishFormScreen(wish: wish));

  Future<void> _delete(BuildContext context, WidgetRef ref, Wish wish) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await confirmDelete(
      context,
      title: l10n.wishDelete,
      body: l10n.wishDeleteConfirm(wish.title),
    );
    if (!confirmed || !context.mounted) return;

    final deleted = await guardDelete(
      context,
      () => ref.read(wishRepositoryProvider).delete(wish.id),
    );
    if (deleted) navigator.pop();
  }

  /// Moves it into the section it belongs to, and says where it went.
  Future<void> _fulfil(BuildContext context, WidgetRef ref, Wish wish) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final root = Navigator.of(context, rootNavigator: true).context;

    Fulfilled? moved;
    final done = await guardSave(context, () async {
      moved = await ref.read(wishFulfilmentProvider).fulfil(wish);
    });
    if (!done || moved == null) return;

    navigator.pop();

    final landed = moved!;
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (landed.domain) {
          TrackedDomain.games => l10n.wishMovedToGames,
          TrackedDomain.concerts => l10n.wishMovedToConcerts,
          _ => l10n.wishMovedToScreen,
        }),
        action: SnackBarAction(
          label: l10n.wishMovedOpen,
          // Opened over the app rather than inside the watchlist, which is
          // no longer where this entry lives.
          onPressed: () => showEntryDialog(
            root,
            detailScreenFor(landed.domain, landed.id),
            wide: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wish = ref.watch(wishProvider(wishId));
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (wish.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, wish.value!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.wishDelete,
              onPressed: () => _delete(context, ref, wish.value!),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: wish.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.retry,
            body: '$error',
          ),
          data: (value) {
            if (value == null) {
              return EmptyState(
                icon: Icons.bookmark_border,
                title: l10n.watchlistEmptyTitle,
              );
            }

            final added = DateFormat.yMMMd(locale).format(value.addedOn);
            final heading = [
              Text(value.title, style: context.text.headlineSmall),
              const SizedBox(height: 2),
              Text(
                [
                  wishKindLabel(l10n, value.kind),
                  ?value.releaseYear?.toString(),
                ].join(' · '),
                style: context.text.bodySmall,
              ),
            ];

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                if (value.posterUrl case final art?)
                  ArtHeader(
                    backdropUrl: art,
                    posterUrl: art,
                    heading: heading,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Gap.md,
                      Gap.md,
                      Gap.md,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: heading,
                    ),
                  ),
                ContentColumn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap.vLg,
                      FilledButton.icon(
                        onPressed: () => _fulfil(context, ref, value),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(wishDoneLabel(l10n, value.kind)),
                      ),
                      Gap.vXs,
                      Text(
                        l10n.wishMovedBody,
                        style: context.text.bodySmall?.copyWith(
                          color: context.semantics.muted,
                        ),
                      ),
                      if (value.note case final note?) ...[
                        Gap.vLg,
                        SectionLabel(l10n.wishNote),
                        Text(note, style: context.text.bodyMedium),
                      ],
                      if (value.description case final description?) ...[
                        Gap.vLg,
                        SectionLabel(l10n.fieldDescription),
                        Text(description, style: context.text.bodyMedium),
                      ],
                      Gap.vLg,
                      Text(
                        l10n.wishAdded(added),
                        style: context.text.bodySmall?.copyWith(
                          color: context.semantics.muted,
                        ),
                      ),
                      Gap.vXl,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
