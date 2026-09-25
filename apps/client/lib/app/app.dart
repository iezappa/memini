import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/accent_backdrop.dart';
import '../core/theme/theme.dart';
import '../features/backup/presentation/database_gate.dart';
import '../features/security/presentation/lock_screen.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'router.dart';

class MeminiApp extends ConsumerWidget {
  const MeminiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accent = ref.watch(accentProvider);
    final pinEnabled = ref.watch(pinEnabledProvider).valueOrNull ?? false;
    final unlocked = ref.watch(unlockedProvider);

    // The router is only built once the app is actually reachable: mounting it
    // behind the lock would run the collection query before unlocking.
    final locked = pinEnabled && !unlocked;

    // A first run does not get a screen of its own any more: the app builds
    // as usual and the tour opens over it, from `OnboardingCheck` inside the
    // router. The lock is the only thing that still replaces the app, and it
    // has to — there is nothing to show until it is cleared.
    if (locked) {
      return MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: MeminiTheme.light(accent),
        darkTheme: MeminiTheme.dark(accent),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: _gated,
        home: const LockScreen(),
      );
    }

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: MeminiTheme.light(accent),
      darkTheme: MeminiTheme.dark(accent),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: _gated,
      routerConfig: ref.watch(routerProvider),
    );
  }

  /// The database gate goes over everything: there is no point greeting, or
  /// unlocking, an app whose store would not open. The backdrop goes under
  /// everything, for the same reason it is not painted per screen.
  static Widget _gated(BuildContext context, Widget? child) => AccentBackdrop(
    child: DatabaseGate(child: child ?? const SizedBox.shrink()),
  );
}
