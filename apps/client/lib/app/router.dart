import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/theme.dart';
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
import '../features/rooms/presentation/room_list_screen.dart';
import '../features/screen/presentation/viewing_detail_screen.dart';
import '../features/screen/presentation/viewing_form_screen.dart';
import '../features/screen/presentation/viewing_list_screen.dart';
import '../features/rooms/presentation/room_detail_screen.dart';
import '../features/rooms/presentation/room_form_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
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
      ..._domainRoutes(
        segment: 'rooms',
        list: () => const RoomListScreen(),
        form: () => const RoomFormScreen(),
        detail: (id) => RoomDetailScreen(roomId: id),
      ),
      ..._domainRoutes(
        segment: 'meals',
        list: () => const MealListScreen(),
        form: () => const MealFormScreen(),
        detail: (id) => MealDetailScreen(mealId: id),
      ),
      ..._domainRoutes(
        segment: 'gigs',
        list: () => const GigListScreen(),
        form: () => const GigFormScreen(),
        detail: (id) => GigDetailScreen(gigId: id),
      ),
      ..._domainRoutes(
        segment: 'viewings',
        list: () => const ViewingListScreen(),
        form: () => const ViewingFormScreen(),
        detail: (id) => ViewingDetailScreen(viewingId: id),
      ),
      ..._domainRoutes(
        segment: 'games',
        list: () => const GameListScreen(),
        form: () => const GameFormScreen(),
        detail: (id) => GameDetailScreen(gameId: id),
      ),
    ],
  );
});

/// The three routes every domain needs: its list, the add form, and one
/// entry. Declared once so a sixth domain is three lines, not thirty.
///
/// The `/new` route has to be declared before `/:id`, or go_router would
/// match "new" as an id and hand the detail screen a null.
List<RouteBase> _domainRoutes({
  required String segment,
  required Widget Function() list,
  required Widget Function() form,
  required Widget Function(int id) detail,
}) {
  return [
    GoRoute(path: '/$segment', builder: (context, state) => list()),
    GoRoute(path: '/$segment/new', builder: (context, state) => form()),
    GoRoute(
      path: '/$segment/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return id == null ? list() : detail(id);
      },
    ),
  ];
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

    final destinations = [
      (Icons.home_outlined, Icons.home, l10n.navHome),
      (Icons.insights_outlined, Icons.insights, l10n.navStats),
      (Icons.settings_outlined, Icons.settings, l10n.navSettings),
    ];

    if (!wide) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: shell.goBranch,
          destinations: [
            for (final (icon, selected, label) in destinations)
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(selected),
                label: label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: shell.goBranch,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            destinations: [
              for (final (icon, selected, label) in destinations)
                NavigationRailDestination(
                  icon: Icon(icon),
                  selectedIcon: Icon(selected),
                  label: Text(label),
                ),
            ],
          ),
          VerticalDivider(width: 1, color: context.semantics.hairline),
          Expanded(child: shell),
        ],
      ),
    );
  }
}
