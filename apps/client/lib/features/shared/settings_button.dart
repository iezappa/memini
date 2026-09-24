import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// The way into settings, from inside whatever screen the user is on.
///
/// Settings used to be a tab, which spent one of the few slots in the bar on
/// a screen nobody visits twice a week — and the bar is where the app's
/// sections belong, not its configuration. It is the same gear on every
/// screen instead, in the same corner, so it is never somewhere different
/// depending on where you are.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  /// The route it opens, outside the shell: pushed over whatever tab is
  /// open, with a real back arrow.
  static const route = '/settings';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: l10n.navSettings,
      onPressed: () => context.push(route),
    );
  }
}
