import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/backup/presentation/backup_actions.dart';
import 'package:memini/features/concerts/presentation/gig_list_screen.dart';
import 'package:memini/features/dining/presentation/meal_list_screen.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/games/presentation/game_list_screen.dart';
import 'package:memini/features/home/presentation/home_screen.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/rooms/presentation/room_list_screen.dart';
import 'package:memini/features/screen/presentation/viewing_list_screen.dart';
import 'package:memini/features/security/data/pin_service.dart';
import 'package:memini/features/settings/presentation/settings_screen.dart';
import 'package:memini/features/stats/presentation/stats_screen.dart';

import '../support/harness.dart';

/// WCAG 2.2 AA as far as a widget test can see it (CUMPLIMIENTO.md 1.4):
/// tap targets, labels on tappable things, and text contrast, in both themes.
void main() {
  late AppDatabase database;

  setUp(() => database = memoryDatabase());
  tearDown(() => database.close());

  final screens = <String, Widget>{
    'settings': const SettingsScreen(),
    'home': const HomeScreen(),
    'stats': const StatsScreen(),
    'escape rooms': const RoomListScreen(),
    'meals': const MealListScreen(),
    'concerts': const GigListScreen(),
    'screen': const ViewingListScreen(),
    'games': const GameListScreen(),
  };

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} meets the accessibility guidelines '
          '(${mode.name})', (tester) async {
        final franchise = await DriftFranchiseRepository(database)
            .create(const FranchiseDraft(name: 'Enigma'));
        await DriftRoomRepository(database).create(
          RoomDraft(
            title: 'The Vault',
            franchiseId: franchise.id,
            rating: 9.5,
            happenedOn: DateTime(2026, 3, 14),
            escaped: true,
            timeLeftMinutes: 4,
          ),
        );

        useTallSurface(tester);
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          await harness(
            entry.value,
            database: database,
            themeMode: mode,
            overrides: [
              pinServiceProvider.overrideWithValue(
                PinService(InMemorySecureStore()),
              ),
              backupFilesProvider.overrideWithValue(FakeBackupFiles()),
            ],
          ),
        );
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        semantics.dispose();
        await unmount(tester);
      });
    }
  }
}
