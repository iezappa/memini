import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/tracking/presentation/tracker_card.dart';
import '../../../core/tracking/presentation/tracker_list_screen.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/game.dart';
import 'game_labels.dart';
import 'game_providers.dart';

class GameListScreen extends ConsumerWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(gameFilterProvider);
    final controller = ref.read(gameFilterProvider.notifier);
    final platforms = ref.watch(gamePlatformsProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return TrackerListScreen(
      labels: TrackerListLabels(
        title: l10n.domainGames,
        searchHint: l10n.gameSearchHint,
        count: l10n.gameCount,
        addAction: l10n.addGame,
        emptyTitle: l10n.gameEmptyTitle,
        emptyBody: l10n.gameEmptyBody,
        emptyFiltered: l10n.gameEmptyFiltered,
        clearFilters: l10n.clearFilters,
        sortLabel: (sort) => trackingSortLabel(l10n, sort),
      ),
      emptyIcon: Icons.sports_esports_outlined,
      entries: ref.watch(gamesProvider).valueOrNull,
      filter: filter,
      onQueryChanged: controller.setQuery,
      onSortChanged: controller.setSort,
      onClearFilters: controller.clear,
      onAdd: () => context.push('/games/new'),
      filterChips: [
        PopupMenuButton<GameStatus?>(
          onSelected: controller.setStatus,
          itemBuilder: (context) => [
            PopupMenuItem(value: null, child: Text(l10n.filterAllStatuses)),
            for (final status in GameStatus.values)
              PopupMenuItem(
                value: status,
                child: Text(gameStatusLabel(l10n, status)),
              ),
          ],
          child: ChipShell(
            label: filter.status == null
                ? l10n.filterStatus
                : gameStatusLabel(l10n, filter.status!),
            selected: filter.status != null,
          ),
        ),
        if (platforms.isNotEmpty)
          PopupMenuButton<String?>(
            onSelected: controller.setPlatform,
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(l10n.filterAllPlatforms)),
              for (final platform in platforms)
                PopupMenuItem(value: platform, child: Text(platform)),
            ],
            child: ChipShell(
              label: filter.platform ?? l10n.filterPlatform,
              selected: filter.platform != null,
            ),
          ),
      ],
      cardBuilder: (context, game) {
        final date = DateFormat.yMMMd(locale).format(game.happenedOn);
        final platform = game.platform;
        return TrackerCard(
          title: game.title,
          subtitle: platform == null ? date : '$platform · $date',
          photoPath: game.photoPath,
          rating: game.rating,
          placeholderIcon: Icons.sports_esports_outlined,
          pill: _StatusPill(game: game),
          onTap: () => context.push('/games/${game.id}'),
        );
      },
    );
  }
}

/// How far the owner got, plus the clock when they bothered to record it.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hours = game.hoursPlayed;
    final status = gameStatusLabel(l10n, game.status);
    final label = hours == null
        ? status
        : '$status · ${l10n.hoursValue(_formatHours(hours))}';

    return Text(label, style: Theme.of(context).textTheme.labelMedium);
  }

  /// Whole hours read better than "27.0h"; halves matter, so keep one digit.
  String _formatHours(double hours) => hours == hours.roundToDouble()
      ? '${hours.round()}'
      : hours.toStringAsFixed(1);
}
