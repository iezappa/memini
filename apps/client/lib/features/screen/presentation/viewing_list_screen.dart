import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/tracking/presentation/tracker_card.dart';
import '../../../core/tracking/presentation/tracker_list_screen.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/viewing.dart';
import 'viewing_labels.dart';
import 'viewing_providers.dart';

class ViewingListScreen extends ConsumerWidget {
  const ViewingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(viewingFilterProvider);
    final controller = ref.read(viewingFilterProvider.notifier);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return TrackerListScreen(
      labels: TrackerListLabels(
        title: l10n.domainScreen,
        searchHint: l10n.viewingSearchHint,
        count: l10n.viewingCount,
        addAction: l10n.addViewing,
        emptyTitle: l10n.viewingEmptyTitle,
        emptyBody: l10n.viewingEmptyBody,
        emptyFiltered: l10n.viewingEmptyFiltered,
        clearFilters: l10n.clearFilters,
        sortLabel: (sort) => trackingSortLabel(l10n, sort),
      ),
      emptyIcon: Icons.movie_outlined,
      entries: ref.watch(viewingsProvider).valueOrNull,
      filter: filter,
      onQueryChanged: controller.setQuery,
      onSortChanged: controller.setSort,
      onClearFilters: controller.clear,
      onAdd: () => context.push('/viewings/new'),
      filterChips: [
        PopupMenuButton<ViewingKind?>(
          onSelected: controller.setKind,
          itemBuilder: (context) => [
            PopupMenuItem(value: null, child: Text(l10n.filterAllKinds)),
            for (final kind in ViewingKind.values)
              PopupMenuItem(
                value: kind,
                child: Text(viewingKindLabel(l10n, kind)),
              ),
          ],
          child: ChipShell(
            label: filter.kind == null
                ? l10n.filterKind
                : viewingKindLabel(l10n, filter.kind!),
            selected: filter.kind != null,
          ),
        ),
      ],
      cardBuilder: (context, viewing) {
        final date = DateFormat.yMMMd(locale).format(viewing.happenedOn);
        final year = viewing.releaseYear;
        return TrackerCard(
          title: viewing.title,
          subtitle: year == null ? date : '$year · $date',
          photoPath: viewing.photoPath,
          rating: viewing.rating,
          placeholderIcon: Icons.movie_outlined,
          pill: _KindPill(viewing: viewing),
          onTap: () => context.push('/viewings/${viewing.id}'),
        );
      },
    );
  }
}

/// What kind of thing it was, plus the season when the entry covers one.
class _KindPill extends StatelessWidget {
  const _KindPill({required this.viewing});

  final Viewing viewing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final season = viewing.season;
    final label = season == null
        ? viewingKindLabel(l10n, viewing.kind)
        : '${viewingKindLabel(l10n, viewing.kind)} · ${l10n.seasonValue(season)}';

    return Text(label, style: Theme.of(context).textTheme.labelMedium);
  }
}
