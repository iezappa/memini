import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/app/app_restart.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/backup/presentation/backup_actions.dart';
import 'package:memini/features/backup/presentation/erase_all_data_tile.dart';
import 'package:memini/features/dining/data/drift_meal_repository.dart';
import 'package:memini/features/dining/domain/meal.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/security/data/pin_service.dart';
import 'package:memini/features/shared/photo_storage.dart';
import 'package:memini/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late FakeBackupFiles files;
  late SharedPreferences prefs;
  late InMemorySecureStore secure;
  late Directory documents;
  late File photo;
  late ProviderContainer container;
  late int restarts;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'settings.locale': 'es',
      'settings.theme_mode': 'dark',
      'settings.accent': 'violet',
      'onboarding.tutorial_seen': true,
      'onboarding.disclaimer_accepted': true,
      'onboarding.backup_notice_accepted': true,
      'profile.display_name': 'Zeke',
      'enrichment.tmdb_api_key': 'secret',
      'backup.last_export_at': '2026-09-01T10:00:00.000',
    });
    prefs = await SharedPreferences.getInstance();
    db = memoryDatabase();
    files = FakeBackupFiles();
    secure = InMemorySecureStore();
    await PinService(secure).setPin('1234');
    documents = Directory.systemTemp.createTempSync('memini_erase_');
    restarts = 0;

    final photos = PhotoStorage(documentsDirectory: () async => documents);
    final source = File('${documents.path}/picked.jpg')
      ..writeAsBytesSync([1, 2, 3]);
    photo = File((await photos.store(source.path))!);
    source.deleteSync();

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        backupFilesProvider.overrideWithValue(files),
        sharedPreferencesProvider.overrideWithValue(prefs),
        pinServiceProvider.overrideWithValue(PinService(secure)),
        photoStorageProvider.overrideWithValue(photos),
        restartAppProvider.overrideWithValue(() => restarts++),
      ],
    );

    final franchise = await DriftFranchiseRepository(db)
        .create(const FranchiseDraft(name: 'Enigma'));
    await DriftRoomRepository(db).create(
      RoomDraft(
        title: 'The Vault',
        franchiseId: franchise.id,
        photoPath: photo.path,
        happenedOn: DateTime(2026, 3, 14),
        escaped: true,
      ),
    );
    await DriftMealRepository(db)
        .create(MealDraft(title: 'Ramen', happenedOn: DateTime(2026, 3, 15)));
  });
  tearDown(() async {
    container.dispose();
    await db.close();
    if (documents.existsSync()) documents.deleteSync(recursive: true);
  });

  group('EraseAllDataActions', () {
    test('empties every table', () async {
      await container.read(eraseAllDataActionsProvider).eraseEverything();

      expect(await db.select(db.rooms).get(), isEmpty);
      expect(await db.select(db.franchises).get(), isEmpty);
      expect(await db.select(db.meals).get(), isEmpty);
    });

    test('deletes the photos it had copied in', () async {
      await container.read(eraseAllDataActionsProvider).eraseEverything();

      expect(photo.existsSync(), isFalse);
    });

    test('removes the PIN', () async {
      await container.read(eraseAllDataActionsProvider).eraseEverything();

      expect(await PinService(secure).isEnabled, isFalse);
    });

    test('forgets every preference but language, theme and accent', () async {
      await container.read(eraseAllDataActionsProvider).eraseEverything();

      expect(prefs.getKeys(), {
        'settings.locale',
        'settings.theme_mode',
        'settings.accent',
      });
    });

    test('starts the app over, which lands on onboarding', () async {
      await container.read(eraseAllDataActionsProvider).eraseEverything();

      expect(restarts, 1);
      expect(container.read(settingsRepositoryProvider).tutorialSeen, isFalse);
    });
  });

  group('the confirmation', () {
    Future<void> open(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Pinned: these assertions read the English copy.
            locale: const Locale('en'),
            home: const Scaffold(body: EraseAllDataTile()),
          ),
        ),
      );
      await tester.tap(find.text('Delete all my data'));
      await tester.pumpAndSettle();
    }

    FilledButton eraseButton(WidgetTester tester) =>
        tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Delete everything'),
        );

    testWidgets('will not delete until the word is typed', (tester) async {
      await open(tester);

      expect(eraseButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'delete it');
      await tester.pump();
      expect(eraseButton(tester).onPressed, isNull);
    });

    testWidgets('offers to export first', (tester) async {
      await open(tester);

      await tester.tap(find.text('Export first'));
      // Real file work (the photo goes into the zip): give it real time.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(files.saved, isNotEmpty);
      expect(restarts, 0);
      await unmount(tester);
    });

    testWidgets('backing out deletes nothing', (tester) async {
      await open(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
        await tester.runAsync(() => db.select(db.rooms).get()),
        hasLength(1),
      );
      expect(restarts, 0);
    });

    testWidgets('deletes once the word is typed and confirmed', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      await tester.tap(find.text('Delete everything'));
      // Real file and database work: give it real time, a few times over.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(restarts, 1);
      expect(await tester.runAsync(() => db.select(db.rooms).get()), isEmpty);
    });
  });
}
