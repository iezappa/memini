import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/entry_dialog.dart';
import '../../shared/entry_screens.dart';
import '../../shared/settings_button.dart';
import '../../shared/widgets.dart';
import 'home_providers.dart';
import 'widgets/activity_grid_card.dart';
import 'widgets/suggestion_shelf.dart';

/// The hub: what the last six months look like, three figures about it, a
/// shortcut into each form, and whatever was logged last.
///
/// The five domain tiles are gone. With a tab per section, a tile that said
/// a number and the name of the tab underneath was a second copy of the
/// navigation taking up half the page. What replaces them is what the
/// navigation cannot tell you: how much is in there, how you score things,
/// and whether you have been out this month.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(displayNameProvider);
    final recent = ref.watch(recentEntriesProvider);

    return Scaffold(
      body: SafeArea(
        child: ContentColumn(
          child: ListView(
            padding: const EdgeInsets.only(bottom: Gap.xl),
            children: [
              Gap.vSm,
              // The gear lives on the screen, not in the bar: the bar is for
              // the app's sections, and settings is not one of them.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name == null
                              ? l10n.greetingAnonymous
                              : l10n.greeting(name),
                          style: context.text.displaySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(l10n.homeTagline, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  const SettingsButton(),
                ],
              ),
              Gap.vLg,
              _SectionHeader(
                label: l10n.homeActivity,
                icon: Icons.calendar_today_outlined,
              ),
              const ActivityGridCard(),
              Gap.vLg,
              _SectionHeader(
                label: l10n.homeShortcuts,
                icon: Icons.add_circle_outline,
              ),
              const _Shortcuts(),
              Gap.vLg,
              _SectionHeader(
                label: l10n.homeSuggestions,
                icon: Icons.auto_awesome_outlined,
              ),
              const SuggestionShelf(),
              Gap.vLg,
              _SectionHeader(
                label: l10n.homeNumbers,
                icon: Icons.insights_outlined,
              ),
              const _Numbers(),
              Gap.vLg,
              _SectionHeader(
                label: l10n.homeRecent,
                icon: Icons.history_outlined,
              ),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.md),
                  child: Text(
                    l10n.homeRecentEmpty,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.semantics.muted,
                    ),
                  ),
                )
              else
                for (final item in recent) _RecentRow(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

/// The heading over one block of the hub.
///
/// Five blocks ran together under five identical labels, and reading the
/// page meant reading every word of it to find where one thing ended and
/// the next began. An icon gives each block a shape to recognise from
/// across the page, and the rule carries the eye to the edge so the break
/// is visible before anything is read.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs),
      child: Row(
        children: [
          // The label carries the standard's own bottom padding, so the
          // icon and the rule take the same one — otherwise the row centres
          // three boxes of three different heights and nothing lines up.
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.sm),
            child: Icon(icon, size: 15, color: context.colors.primary),
          ),
          Gap.hSm,
          // The app's standard section label, kept as it is everywhere else;
          // only what surrounds it is new.
          SectionLabel(label),
          Gap.hMd,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm),
              child: Divider(height: 1, color: context.semantics.hairline),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.item});

  final DomainEntry item;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final entry = item.entry;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(item.domain.icon, color: context.semantics.muted),
      title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(DateFormat.yMMMd(locale).format(entry.happenedOn)),
      trailing: ScoreBadge(rating: entry.rating),
      onTap: () => showEntryDialog(
        context,
        detailScreenFor(item.domain, entry.id),
        wide: true,
      ),
    );
  }
}

/// One chip per domain, straight to its form.
///
/// The tiles above answer "how much have I got"; these answer "I want to
/// write something down now", which is the other reason the hub is opened.
/// A tap lands on the form rather than on the list: the list is a tab away.
class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: Gap.sm,
      runSpacing: Gap.sm,
      children: [
        for (final domain in TrackedDomain.values)
          ActionChip(
            avatar: Icon(domain.icon, size: 18),
            label: Text(domain.label(l10n)),
            onPressed: () => showEntryDialog(context, formScreenFor(domain)),
          ),
      ],
    );
  }
}

/// Three figures about the whole collection.
///
/// Laid out as a row that wraps, not a grid: they are three short facts, and
/// a grid would give each of them a box the size of a card.
class _Numbers extends ConsumerWidget {
  const _Numbers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final numbers = ref.watch(homeNumbersProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    // Three tiles of equal width rather than three figures floating in a
    // wrap: the numbers are the same, but a row of tiles reads as a panel
    // instead of as a sentence that ran out of punctuation.
    return Row(
      children: [
        Expanded(
          child: _Number(
            label: l10n.homeStatEntries,
            value: '${numbers.entries}',
          ),
        ),
        Gap.hSm,
        Expanded(
          child: _Number(
            label: l10n.homeStatRating,
            // One decimal: the difference between 7.8 and 7.9 is the whole
            // point of keeping a score, and 7.83 is not a thing anyone means.
            value: numbers.rating == null
                ? l10n.homeStatNone
                : NumberFormat('0.0', locale).format(numbers.rating),
          ),
        ),
        Gap.hSm,
        Expanded(
          child: _Number(
            label: l10n.homeStatThisMonth,
            value: '${numbers.thisMonth}',
          ),
        ),
      ],
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.md,
        vertical: Gap.md - 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: Radii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.text.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: context.semantics.muted,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
