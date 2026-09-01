import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';
import 'home_providers.dart';

/// The hub: every domain at a glance, plus whatever was logged last.
///
/// Five domains do not fit in a bottom bar without turning it into a remote
/// control, so the bar keeps three tabs and the domains live one tap deeper.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(displayNameProvider);
    final counts = ref.watch(domainCountsProvider);
    final recent = ref.watch(recentEntriesProvider);

    return Scaffold(
      body: SafeArea(
        child: ContentColumn(
          child: ListView(
            padding: const EdgeInsets.only(bottom: Gap.xl),
            children: [
              Gap.vLg,
              Text(
                name == null ? l10n.greetingAnonymous : l10n.greeting(name),
                style: context.text.displaySmall,
              ),
              const SizedBox(height: 2),
              Text(l10n.homeTagline, style: context.text.bodySmall),
              Gap.vLg,
              LayoutBuilder(
                builder: (context, constraints) {
                  // Two tiles fit a phone, three anything wider; the fifth
                  // tile simply wraps rather than getting a row of its own.
                  final columns = constraints.maxWidth >= 560 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: Gap.sm,
                    crossAxisSpacing: Gap.sm,
                    childAspectRatio: 1.55,
                    children: [
                      for (final domain in TrackedDomain.values)
                        _DomainTile(domain: domain, count: counts[domain] ?? 0),
                    ],
                  );
                },
              ),
              Gap.vLg,
              SectionLabel(l10n.homeRecent),
              Gap.vSm,
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

class _DomainTile extends StatelessWidget {
  const _DomainTile({required this.domain, required this.count});

  final TrackedDomain domain;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(domain.route),
        child: Padding(
          padding: const EdgeInsets.all(Gap.md - 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(domain.icon, size: 22, color: context.semantics.muted),
              Text('$count', style: context.text.headlineMedium),
              Text(
                domain.label(l10n),
                style: context.text.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
      onTap: () => context.push('${item.domain.route}/${entry.id}'),
    );
  }
}
