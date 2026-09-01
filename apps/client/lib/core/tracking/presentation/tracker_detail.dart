import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../features/shared/widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';

/// The detail layout every domain shares: cover, title, one line of context,
/// the score, then whatever the domain wants to add.
class TrackerDetailBody extends StatelessWidget {
  const TrackerDetailBody({
    super.key,
    required this.title,
    required this.happenedOn,
    required this.rating,
    this.photoPath,
    this.placeholderIcon = Icons.bookmark_outline,
    this.contextLine,
    this.badge,
    this.description,
    this.review,
    this.facts = const [],
    this.extra = const [],
  });

  final String title;
  final DateTime happenedOn;
  final double? rating;
  final String? photoPath;
  final IconData placeholderIcon;

  /// Shown before the date, e.g. a venue or a franchise.
  final String? contextLine;

  /// The domain's own badge, beside the score.
  final Widget? badge;

  final String? description;
  final String? review;

  /// Short label/value pairs — director, platform, price. Empty values are
  /// dropped by the caller, so a sparse entry never shows blank rows.
  final List<({String label, String value})> facts;

  /// Anything the domain needs that is not a fact row, such as a setlist.
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMMd(locale).format(happenedOn);

    return ContentColumn(
      child: ListView(
        padding: const EdgeInsets.only(bottom: Gap.xl),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: EntryPhoto(
              path: photoPath,
              width: double.infinity,
              placeholderIcon: placeholderIcon,
            ),
          ),
          Gap.vLg,
          Text(title, style: context.text.displaySmall),
          Gap.vXs,
          Text([?contextLine, date].join(' · '), style: context.text.bodySmall),
          Gap.vMd,
          Row(
            children: [
              ScoreBadge(rating: rating, large: true),
              if (badge != null) ...[Gap.hMd, badge!],
            ],
          ),
          if (facts.isNotEmpty) ...[
            Gap.vXl,
            for (final fact in facts) _FactRow(fact: fact),
          ],
          if (description != null) ...[
            Gap.vXl,
            SectionLabel(l10n.fieldDescription),
            Gap.vSm,
            Text(description!, style: context.text.bodyLarge),
          ],
          ...extra,
          if (review != null) ...[
            Gap.vXl,
            SectionLabel(l10n.fieldReview),
            Gap.vSm,
            Text(review!, style: context.text.bodyLarge),
          ],
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact});

  final ({String label, String value}) fact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              fact.label,
              style: context.text.bodySmall?.copyWith(
                color: context.semantics.muted,
              ),
            ),
          ),
          Gap.hSm,
          Expanded(child: Text(fact.value, style: context.text.bodyLarge)),
        ],
      ),
    );
  }
}

/// Confirms a destructive delete. Returns true only on an explicit yes.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
