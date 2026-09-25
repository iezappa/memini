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
///
/// Except where the rail is showing, which has a gear of its own at its
/// foot. Two gears on one screen is not twice as easy to find; it is a
/// question about whether they do the same thing.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  /// The branch it opens. Inside the shell, so the navigation stays put.
  static const route = '/settings';

  /// The width at or above which the rail appears, and this stands down.
  /// The same number `_HomeShell` chooses the rail at.
  static const railFrom = 720.0;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= railFrom) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);

    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: l10n.navSettings,
      onPressed: () => context.go(route),
    );
  }
}
