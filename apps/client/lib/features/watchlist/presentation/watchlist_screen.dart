import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/tracking/presentation/tracker_list_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/entry_dialog.dart';
import '../domain/wish.dart';
import 'wish_detail_screen.dart';
import 'wish_form_screen.dart';
import 'wish_labels.dart';
import 'wish_providers.dart';

/// The watchlist, on the same list screen the five tracked sections use.
///
/// Search, ordering, the grid and the pager all come from there. What is
/// different is what a row says: no score, because nothing here has been
/// seen yet, and the day shown is the day it was added.
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(wishFilterProvider);
    final controller = ref.read(wishFilterProvider.notifier);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return TrackerListScreen<Wish>(
      labels: TrackerListLabels(
        title: l10n.watchlistTitle,
        searchHint: l10n.watchlistSearchHint,
        count: l10n.watchlistCount,
        addAction: l10n.watchlistAdd,
        emptyTitle: l10n.watchlistEmptyTitle,
        emptyBody: l10n.watchlistEmptyBody,
        emptyFiltered: l10n.watchlistEmptyFiltered,
        clearFilters: l10n.clearFilters,
        sortLabel: (sort) => wishSortLabel(l10n, sort),
        sorts: kWishSorts,
      ),
      emptyIcon: Icons.bookmark_border,
      entries: ref.watch(wishesProvider).valueOrNull,
      filter: filter,
      onQueryChanged: controller.setQuery,
      onSortChanged: controller.setSort,
      onClearFilters: controller.clear,
      onAdd: () => showEntryDialog(context, const WishFormScreen()),
      filterChips: [
        PopupMenuButton<WishKind?>(
          onSelected: controller.setKind,
          itemBuilder: (context) => [
            PopupMenuItem(value: null, child: Text(l10n.wishKindAll)),
            for (final kind in WishKind.values)
              PopupMenuItem(value: kind, child: Text(wishKindLabel(l10n, kind))),
          ],
          child: ChipShell(
            label: filter.kind == null
                ? l10n.wishKindAll
                : wishKindLabel(l10n, filter.kind!),
            selected: filter.kind != null,
          ),
        ),
      ],
      entryBuilder: (context, wish) {
        final added = DateFormat.yMMMd(locale).format(wish.addedOn);
        return (
          title: wish.title,
          // The kind and the year, then when it was added: enough to tell
          // two things of the same name apart without opening either.
          subtitle: [
            wishKindLabel(l10n, wish.kind),
            ?wish.releaseYear?.toString(),
            added,
          ].join(' · '),
          // Nothing here has been watched, so nothing here has a score.
          rating: null,
          icon: wishKindIcon(wish.kind),
          posterUrl: wish.posterUrl,
          // A wish carries no photographs: it is a thing you have not done.
          photoOwnerId: null,
          pill: null,
          onTap: () => showEntryDialog(
            context,
            WishDetailScreen(wishId: wish.id),
            wide: true,
          ),
        );
      },
    );
  }
}
