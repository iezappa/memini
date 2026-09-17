import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/release_notes.dart';

/// Shows [releases], newest first.
///
/// With [announcing] it is the "what's new" after an update, titled with the
/// newest version; otherwise it is the full history opened from settings.
Future<void> showReleaseNotesDialog(
  BuildContext context, {
  required List<ReleaseNote> releases,
  bool announcing = false,
}) => showDialog<void>(
  context: context,
  builder: (context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        announcing
            ? l10n.whatsNewTitle('${releases.first.version}')
            : l10n.releaseNotesHistory,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(child: _Releases(releases: releases)),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.whatsNewClose),
        ),
      ],
    );
  },
);

class _Releases extends StatelessWidget {
  const _Releases({required this.releases});

  final List<ReleaseNote> releases;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final release in releases) ...[
          if (release != releases.first) Gap.vMd,
          Row(
            children: [
              Expanded(
                child: Text(
                  '${release.version}',
                  style: context.text.titleMedium,
                ),
              ),
              Text(
                DateFormat.yMMMd(locale).format(release.date),
                style: context.text.bodySmall,
              ),
            ],
          ),
          Gap.vSm,
          for (final line in release.highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: context.text.bodyMedium),
                  Expanded(child: Text(line, style: context.text.bodyMedium)),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
