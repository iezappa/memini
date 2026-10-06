import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'nav_rail.dart';
import '../features/backup/presentation/backup_notice.dart';
import '../features/books/presentation/book_detail_screen.dart';
import '../features/books/presentation/book_form_screen.dart';
import '../features/books/presentation/book_list_screen.dart';
import '../features/backup/presentation/backup_reminder_banner.dart';
import '../features/backup/presentation/storage_warning_banner.dart';
import '../features/concerts/presentation/gig_detail_screen.dart';
import '../features/concerts/presentation/gig_form_screen.dart';
import '../features/concerts/presentation/gig_list_screen.dart';
import '../features/dining/presentation/meal_detail_screen.dart';
import '../features/dining/presentation/meal_form_screen.dart';
import '../features/dining/presentation/meal_list_screen.dart';
import '../features/games/presentation/game_detail_screen.dart';
import '../features/games/presentation/game_form_screen.dart';
import '../features/games/presentation/game_list_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_check.dart';
import '../features/update/presentation/update_banner.dart';
import '../features/release_notes/presentation/whats_new_check.dart';
import '../features/rooms/presentation/room_list_screen.dart';
import '../features/screen/presentation/viewing_detail_screen.dart';
import '../features/screen/presentation/viewing_form_screen.dart';
import '../features/screen/presentation/viewing_list_screen.dart';
import '../features/rooms/presentation/room_detail_screen.dart';
import '../features/rooms/presentation/room_form_screen.dart';
import '../core/tracking/presentation/tracking_labels.dart';
import '../features/server_account/presentation/server_account_providers.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/watchlist/presentation/watchlist_screen.dart';
import '../features/watchlist/presentation/wish_detail_screen.dart';
import '../features/watchlist/presentation/wish_form_screen.dart';
import '../l10n/app_localizations.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // One branch per domain, so each of the five is a tab and keeps
          // its own scroll position and its own search box. Their forms and
          // detail pages are branch routes rather than top-level ones: the
          // bar stays put while the user is inside one, which is what makes
          // it a section rather than a detour.
          _domainBranch(
            segment: 'rooms',
            list: () => const RoomListScreen(),
            form: () => const RoomFormScreen(),
            detail: (id) => RoomDetailScreen(roomId: id),
          ),
          _domainBranch(
            segment: 'meals',
            list: () => const MealListScreen(),
            form: () => const MealFormScreen(),
            detail: (id) => MealDetailScreen(mealId: id),
          ),
          _domainBranch(
            segment: 'gigs',
            list: () => const GigListScreen(),
            form: () => const GigFormScreen(),
            detail: (id) => GigDetailScreen(gigId: id),
          ),
          _domainBranch(
            segment: 'viewings',
            list: () => const ViewingListScreen(),
            form: () => const ViewingFormScreen(),
            detail: (id) => ViewingDetailScreen(viewingId: id),
          ),
          _domainBranch(
            segment: 'games',
            list: () => const GameListScreen(),
            form: () => const GameFormScreen(),
            detail: (id) => GameDetailScreen(gameId: id),
          ),
          _domainBranch(
            segment: 'books',
            list: () => const BookListScreen(),
            form: () => const BookFormScreen(),
            detail: (id) => BookDetailScreen(bookId: id),
          ),
          // Between the five sections and the figures, which is where it
          // belongs: it is a list of entries like they are, but of the ones
          // that have not happened yet.
          _domainBranch(
            segment: 'watchlist',
            list: () => const WatchlistScreen(),
            form: () => const WishFormScreen(),
            detail: (id) => WishDetailScreen(wishId: id),
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          // Inside the shell, like everything else. It used to be pushed
          // over the whole app with a back arrow, which made configuring
          // the app feel like leaving it — and on a wide window it took the
          // navigation off screen to show a list of switches. It is a
          // branch now: the rail stays put and settings opens beside it,
          // and it keeps its own scroll position like every other section.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// One domain as a tab: its list, the add form, and one entry.
///
/// Declared once so a sixth domain is five lines, not fifty. The form and
/// the detail hang off the list as children, which is what keeps them in
/// the same branch — and the bar on screen — instead of covering the app.
///
/// The `new` child has to be declared before `:id`, or go_router would
/// match "new" as an id and hand the detail screen a null.
StatefulShellBranch _domainBranch({
  required String segment,
  required Widget Function() list,
  required Widget Function() form,
  required Widget Function(String id) detail,
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/$segment',
        builder: (context, state) => list(),
        routes: [
          GoRoute(path: 'new', builder: (context, state) => form()),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return id == null || id.isEmpty ? list() : detail(id);
            },
          ),
        ],
      ),
    ],
  );
}

/// Bottom navigation on phones, a rail on anything wider — one shell so the
/// three branches keep their own scroll position either way.
class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 720;

    // Home, the five sections, the watchlist and the figures — in the order
    // the domains are declared in, so the bar reads the same as everything
    // else.
    final destinations = [
      (Icons.home_outlined, Icons.home, l10n.navHome),
      for (final domain in TrackedDomain.values)
        (domain.icon, domain.icon, domain.label(l10n)),
      (Icons.bookmark_border, Icons.bookmark, l10n.navWatchlist),
      (Icons.insights_outlined, Icons.insights, l10n.navStats),
    ];

    // Settings is the last branch, and it is not one of the sections: on a
    // wide window it sits at the foot of the rail, below a rule; on a phone
    // it stays the gear in the corner of every screen, because a bottom bar
    // has no foot to put it at.
    const settingsBranch = 9;

    if (!wide) {
      return Scaffold(
        body: _WithNotices(child: shell),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: shell.goBranch,
          // Icons alone. Seven labels do not fit a phone's width without
          // being clipped to two syllables each, and clipped labels are
          // worse than none: the icon says which section it is, and the
          // screen it opens is titled.
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: [
            for (final (icon, selected, label) in destinations)
              // The label is still given: with the text hidden it is what
              // the tooltip and the screen reader read out.
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(selected),
                label: label,
                tooltip: label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavRail(
            destinations: destinations,
            selectedIndex: shell.currentIndex,
            onSelected: shell.goBranch,
            footer: (Icons.settings_outlined, Icons.settings, l10n.navSettings),
            footerSelected: shell.currentIndex == settingsBranch,
            onFooterSelected: () => shell.goBranch(settingsBranch),
          ),
          Expanded(child: _WithNotices(child: shell)),
        ],
      ),
    );
  }
}

/// The tab, with any data-safety notice docked under it.
///
/// At the bottom rather than the top: the tabs bring their own app bars and
/// status-bar insets, and a banner pushed above them would sit between the
/// clock and the title. Down here it covers nothing and blocks nothing.
class _WithNotices extends StatelessWidget {
  const _WithNotices({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => OnboardingCheck(
    child: BackupNoticeCheck(
      child: WhatsNewCheck(
        child: Column(
          children: [
            Expanded(child: child),
            const UpdateBanner(),
            const StorageWarningBanner(),
            const BackupReminderBanner(),
            const _AutoBackupTrigger(),
          ],
        ),
      ),
    ),
  );
}

class _AutoBackupTrigger extends ConsumerStatefulWidget {
  const _AutoBackupTrigger();

  @override
  ConsumerState<_AutoBackupTrigger> createState() => _AutoBackupTriggerState();
}

class _AutoBackupTriggerState extends ConsumerState<_AutoBackupTrigger> {
  static const _interval = Duration(minutes: 2);

  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runOnce();
      _timer = Timer.periodic(_interval, (_) => _runOnce());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _runOnce() async {
    if (_running) return;
    _running = true;
    try {
      await ref.read(serverAccountActionsProvider).runAutomaticBackup();
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
