import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';
import '../domain/room_stats.dart';
import 'stats_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(meminiStatsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navStats)),
      body: SafeArea(
        child: stats.isEmpty
            ? EmptyState(icon: Icons.insights_outlined, title: l10n.statsEmpty)
            : const _StatsBody(),
      ),
    );
  }
}

class _StatsBody extends ConsumerWidget {
  const _StatsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(meminiStatsProvider);
    final rooms = ref.watch(statsProvider).valueOrNull ?? RoomStats.empty;
    final hours = ref.watch(hoursPlayedProvider);
    final spent = ref.watch(moneySpentProvider);
    final average = stats.averageRating;

    return ContentColumn(
      child: ListView(
        padding: const EdgeInsets.only(bottom: Gap.xl),
        children: [
          Gap.vMd,
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.statsEntries,
                  value: '${stats.total}',
                ),
              ),
              Gap.hSm,
              Expanded(
                child: _StatTile(
                  label: l10n.statsAverage,
                  value: average == null ? '—' : average.toStringAsFixed(1),
                  accent: context.colors.primary,
                ),
              ),
            ],
          ),
          Gap.vSm,
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.statsRated,
                  value: '${stats.rated}',
                ),
              ),
              Gap.hSm,
              Expanded(
                child: _StatTile(
                  label: l10n.statsEscapeRate,
                  value: rooms.escapeRate == null
                      ? '—'
                      : '${(rooms.escapeRate! * 100).toStringAsFixed(0)}%',
                  accent: context.semantics.escaped,
                ),
              ),
            ],
          ),
          if (hours != null || spent != null) ...[
            Gap.vSm,
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: l10n.statsHoursPlayed,
                    value: hours == null ? '—' : _round(hours),
                  ),
                ),
                Gap.hSm,
                Expanded(
                  child: _StatTile(
                    label: l10n.statsMoneySpent,
                    value: spent == null ? '—' : _round(spent),
                  ),
                ),
              ],
            ),
          ],
          Gap.vXl,
          SectionLabel(l10n.statsByDomain),
          Gap.vSm,
          _DomainBreakdown(counts: stats.perDomain),
          Gap.vXl,
          SectionLabel(l10n.statsBestOverall),
          Gap.vSm,
          if (stats.best == null)
            Text(
              l10n.statsNothingRated,
              style: context.text.bodyMedium?.copyWith(
                color: context.semantics.muted,
              ),
            )
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push(
                  '${stats.best!.domain.route}/${stats.best!.entry.id}',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Gap.md),
                  child: Row(
                    children: [
                      EntryPhoto(
                        path: stats.best!.entry.photoPath,
                        width: 56,
                        height: 56,
                        borderRadius: Radii.field,
                        placeholderIcon: stats.best!.domain.icon,
                      ),
                      Gap.hMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats.best!.entry.title,
                              style: context.text.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              stats.best!.domain.label(l10n),
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      ScoreBadge(rating: stats.best!.entry.rating),
                    ],
                  ),
                ),
              ),
            ),
          Gap.vXl,
          SectionLabel(l10n.statsPerYearAll),
          Gap.vSm,
          _CountBars(
            counts: {
              for (final entry in stats.perYear.entries)
                '${entry.key}': entry.value,
            },
          ),
        ],
      ),
    );
  }

  /// Totals read better whole; a half hour or a stray cent still shows.
  static String _round(double value) => value == value.roundToDouble()
      ? '${value.round()}'
      : value.toStringAsFixed(1);
}

class _DomainBreakdown extends StatelessWidget {
  const _DomainBreakdown({required this.counts});

  final Map<TrackedDomain, int> counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CountBars(
      counts: {
        for (final domain in TrackedDomain.values)
          domain.label(l10n): counts[domain] ?? 0,
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(label),
            Gap.vSm,
            Text(
              value,
              style: context.text.displaySmall?.copyWith(
                color: accent ?? context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal bars instead of a chart library: one dependency less, and at
/// this scale a bar per row is all the shape there is to see.
class _CountBars extends StatelessWidget {
  const _CountBars({required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) return const SizedBox.shrink();

    final peak = counts.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.md),
        child: Column(
          children: [
            for (final entry in counts.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 108,
                      child: Text(
                        entry.key,
                        style: context.text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: Radii.pill,
                        child: LinearProgressIndicator(
                          // A zero peak would divide by zero on an empty log.
                          value: peak == 0 ? 0 : entry.value / peak,
                          minHeight: 10,
                          backgroundColor:
                              context.colors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            context.colors.primary,
                          ),
                        ),
                      ),
                    ),
                    Gap.hSm,
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${entry.value}',
                        textAlign: TextAlign.end,
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
