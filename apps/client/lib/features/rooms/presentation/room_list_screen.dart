import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/tracking/presentation/tracker_card.dart';
import '../../../core/tracking/presentation/tracker_list_screen.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';

class RoomListScreen extends ConsumerWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(roomFilterProvider);
    final controller = ref.read(roomFilterProvider.notifier);
    final franchises = ref.watch(franchisesProvider).valueOrNull ?? const [];
    final franchiseNames = ref.watch(franchiseNamesProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return TrackerListScreen(
      labels: TrackerListLabels(
        title: l10n.domainRooms,
        searchHint: l10n.searchHint,
        count: l10n.roomCount,
        addAction: l10n.addRoom,
        emptyTitle: l10n.emptyTitle,
        emptyBody: l10n.emptyBody,
        emptyFiltered: l10n.emptyFiltered,
        clearFilters: l10n.clearFilters,
        sortLabel: (sort) => trackingSortLabel(l10n, sort),
      ),
      emptyIcon: Icons.meeting_room_outlined,
      entries: ref.watch(roomsProvider).valueOrNull,
      filter: filter,
      onQueryChanged: controller.setQuery,
      onSortChanged: controller.setSort,
      onClearFilters: controller.clear,
      onAdd: () => context.push('/rooms/new'),
      filterChips: [
        FilterChip(
          label: Text(l10n.filterEscaped),
          selected: filter.escaped == true,
          onSelected: (selected) =>
              controller.setEscaped(selected ? true : null),
        ),
        FilterChip(
          label: Text(l10n.filterFailed),
          selected: filter.escaped == false,
          onSelected: (selected) =>
              controller.setEscaped(selected ? false : null),
        ),
        if (franchises.isNotEmpty)
          PopupMenuButton<int?>(
            onSelected: controller.setFranchise,
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(l10n.filterAllFranchises)),
              for (final franchise in franchises)
                PopupMenuItem(value: franchise.id, child: Text(franchise.name)),
            ],
            child: ChipShell(
              label: franchiseNames[filter.franchiseId] ?? l10n.filterFranchise,
              selected: filter.franchiseId != null,
            ),
          ),
      ],
      cardBuilder: (context, room) {
        final date = DateFormat.yMMMd(locale).format(room.happenedOn);
        final franchise = franchiseNames[room.franchiseId];
        return TrackerCard(
          title: room.title,
          subtitle: franchise == null ? date : '$franchise · $date',
          photoPath: room.photoPath,
          rating: room.rating,
          placeholderIcon: Icons.meeting_room_outlined,
          pill: OutcomePill(
            escaped: room.escaped,
            timeLeftMinutes: room.timeLeftMinutes,
          ),
          onTap: () => context.push('/rooms/${room.id}'),
        );
      },
    );
  }
}
