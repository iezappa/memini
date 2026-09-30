import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/time/clock.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/activity_grid.dart';
import '../home_providers.dart';

/// The contribution grid: one square per day, darker the more was logged.
///
/// Reads as a whole before it reads in detail — the shape of the last six
/// months answers "have I been out lately" without a single square being
/// inspected. The numbers under it are there for when the answer is "not
/// much" and the reader wants to know how little.
class ActivityGridCard extends StatelessWidget {
  const ActivityGridCard({super.key});

  /// The squares themselves, so a test can measure what they fill.
  static const squaresKey = Key('activity-squares');

  /// The space one column wants: a square you can aim a cursor at, plus the
  /// hairline of air between it and the next.
  static const _column = 22.0;
  static const gap = 3.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The grid takes as many weeks as the window can show at a readable
        // size, instead of always drawing half a year — which shrank the
        // squares to 7px on a phone and left half of a desktop empty beside
        // them. A wide window gets a year; a phone gets a season.
        final weeks = (constraints.maxWidth / _column).floor().clamp(
          activityWeeksMin,
          activityWeeksMax,
        );

        return Consumer(
          builder: (context, ref, _) =>
              _Grid(weeks: weeks, width: constraints.maxWidth),
        );
      },
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid({required this.weeks, required this.width});

  final int weeks;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final grid = ref.watch(activityGridProvider(weeks));
    final today = ref.watch(clockProvider)();

    // Whatever is left over after the gaps, shared out: the columns fill the
    // width exactly rather than stopping short of it.
    const gap = ActivityGridCard.gap;
    final columns = grid.weeks.length;
    final side = ((width - gap * (columns - 1)) / columns).clamp(7.0, 26.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeActivityCaption(columns),
          style: context.text.bodySmall?.copyWith(
            color: context.semantics.muted,
          ),
        ),
        Gap.vSm,
        Row(
          key: ActivityGridCard.squaresKey,
          // Left, with everything else on the page. Centred it read as a
          // picture dropped into the column rather than as part of it.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, week) in grid.weeks.indexed)
              Padding(
                padding: EdgeInsets.only(right: index == columns - 1 ? 0 : gap),
                child: Column(
                  children: [
                    for (final day in week)
                      Padding(
                        padding: const EdgeInsets.only(bottom: gap),
                        child: _Cell(
                          day: day,
                          side: side,
                          // A day that has not arrived is drawn away rather
                          // than empty: empty would claim the reader had
                          // nothing on.
                          future: day.day.isAfter(dateOnly(today)),
                          l10n: l10n,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        Gap.vSm,
        if (grid.isEmpty)
          Text(
            l10n.homeActivityEmpty,
            style: context.text.bodySmall?.copyWith(
              color: context.semantics.muted,
            ),
          )
        else
          Text(
            [
              l10n.homeActivityTotal(grid.total),
              l10n.homeActivityDays(grid.activeDays),
              l10n.homeActivityRun(grid.longestRun(today)),
            ].join(' · '),
            style: context.text.bodySmall?.copyWith(
              color: context.semantics.muted,
            ),
          ),
        Gap.vSm,
        _Legend(l10n: l10n),
      ],
    );
  }
}

/// One day's square.
class _Cell extends StatelessWidget {
  const _Cell({
    required this.day,
    required this.side,
    required this.future,
    required this.l10n,
  });

  final ActivityDay day;
  final double side;
  final bool future;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final square = Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: future ? Colors.transparent : activityShade(context, day.level),
        borderRadius: BorderRadius.circular(2),
      ),
    );

    // A day that has not happened yet has nothing to say about it, and a
    // tooltip on every one of them would put "nothing logged" under the
    // cursor for dates in the future.
    if (future) return square;

    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(day.day);

    return Tooltip(
      message: day.isEmpty
          ? l10n.homeActivityCellEmpty(date)
          : l10n.homeActivityCell(date, day.count),
      child: square,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final style = context.text.labelSmall?.copyWith(
      color: context.semantics.muted,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(l10n.homeActivityLess, style: style),
        const SizedBox(width: 4),
        for (var level = 0; level <= 4; level++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: activityShade(context, level),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        const SizedBox(width: 2),
        Text(l10n.homeActivityMore, style: style),
      ],
    );
  }
}

/// The fill for a square at [level], 0 through 4.
///
/// One ramp of the app's own accent rather than GitHub's greens: the hub
/// already speaks in this colour, and a second palette here would read as a
/// widget borrowed from somewhere else. Level 0 is drawn in the page's
/// hairline instead of left blank, so an untouched day is still a square
/// and the grid keeps its shape on a dark background as well as a light one.
Color activityShade(BuildContext context, int level) => switch (level) {
  0 => context.semantics.hairline,
  1 => context.colors.primary.withValues(alpha: 0.28),
  2 => context.colors.primary.withValues(alpha: 0.50),
  3 => context.colors.primary.withValues(alpha: 0.74),
  _ => context.colors.primary,
};
