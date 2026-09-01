import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Injected so the flow can be tested without touching the url_launcher
/// platform channel.
typedef UrlOpener = Future<bool> Function(Uri url);

Future<bool> _launchExternally(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

/// Voluntary support links.
///
/// Both platforms are always shown side by side and never chosen for the user
/// by geolocation — an offline-first app must not open a connection just to
/// guess a country.
class SupportProjectsCard extends StatelessWidget {
  const SupportProjectsCard({super.key, this.opener = _launchExternally});

  static final cafecito = Uri.parse('https://cafecito.app/iezappa');
  static final patreon = Uri.parse('https://www.patreon.com/cw/iezappa');

  final UrlOpener opener;

  Future<void> _open(BuildContext context, Uri url) async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = AppLocalizations.of(context).linkFailed;

    var ok = false;
    try {
      ok = await opener(url);
    } catch (_) {
      ok = false;
    }

    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.supportTitle, style: context.text.titleMedium),
            Gap.vXs,
            Text(l10n.supportBody, style: context.text.bodySmall),
            Gap.vMd,
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _open(context, cafecito),
                  icon: const Icon(Icons.local_cafe_outlined, size: 18),
                  label: Text(l10n.supportCafecito),
                ),
                OutlinedButton.icon(
                  onPressed: () => _open(context, patreon),
                  icon: const Icon(Icons.favorite_outline, size: 18),
                  label: Text(l10n.supportPatreon),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
