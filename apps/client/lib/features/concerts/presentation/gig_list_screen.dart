import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/tracking/presentation/tracker_card.dart';
import '../../../core/tracking/presentation/tracker_list_screen.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import 'gig_providers.dart';

class GigListScreen extends ConsumerWidget {
  const GigListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(gigFilterProvider);
    final controller = ref.read(gigFilterProvider.notifier);
    final cities = ref.watch(gigCitiesProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return TrackerListScreen(
      labels: TrackerListLabels(
        title: l10n.domainConcerts,
        searchHint: l10n.gigSearchHint,
        count: l10n.gigCount,
        addAction: l10n.addGig,
        emptyTitle: l10n.gigEmptyTitle,
        emptyBody: l10n.gigEmptyBody,
        emptyFiltered: l10n.gigEmptyFiltered,
        clearFilters: l10n.clearFilters,
        sortLabel: (sort) => trackingSortLabel(l10n, sort),
      ),
      emptyIcon: Icons.music_note_outlined,
      entries: ref.watch(gigsProvider).valueOrNull,
      filter: filter,
      onQueryChanged: controller.setQuery,
      onSortChanged: controller.setSort,
      onClearFilters: controller.clear,
      onAdd: () => context.push('/gigs/new'),
      filterChips: [
        if (cities.isNotEmpty)
          PopupMenuButton<String?>(
            onSelected: controller.setCity,
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(l10n.filterAllCities)),
              for (final city in cities)
                PopupMenuItem(value: city, child: Text(city)),
            ],
            child: ChipShell(
              label: filter.city ?? l10n.filterCity,
              selected: filter.city != null,
            ),
          ),
      ],
      cardBuilder: (context, gig) {
        final date = DateFormat.yMMMd(locale).format(gig.happenedOn);
        final venue = gig.venue;
        return TrackerCard(
          title: gig.title,
          subtitle: venue == null ? date : '$venue · $date',
          photoPath: gig.photoPath,
          rating: gig.rating,
          placeholderIcon: Icons.music_note_outlined,
          pill: gig.supportActs == null
              ? null
              : Text(
                  gig.supportActs!,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          onTap: () => context.push('/gigs/${gig.id}'),
        );
      },
    );
  }
}
