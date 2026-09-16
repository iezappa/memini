import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/time/clock.dart';
import 'package:memini/features/backup/presentation/backup_actions.dart';
import 'package:memini/features/backup/presentation/backup_reminder_banner.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late FakeBackupFiles files;
  final now = DateTime(2026, 9, 16, 10);

  setUp(() {
    db = memoryDatabase();
    files = FakeBackupFiles();
  });
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    await tester.pumpWidget(
      await harness(
        const Scaffold(body: BackupReminderBanner()),
        database: db,
        prefs: prefs,
        overrides: [
          backupFilesProvider.overrideWithValue(files),
          clockProvider.overrideWithValue(() => now),
        ],
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(Scaffold)));

  Future<void> seedRoom() => DriftRoomRepository(db).create(
    RoomDraft(
      title: 'The Vault',
      happenedOn: DateTime(2026, 3, 14),
      escaped: true,
    ),
  );

  testWidgets('says nothing while there is nothing to back up', (tester) async {
    await pump(tester);

    expect(find.byType(MaterialBanner), findsNothing);
    await unmount(tester);
  });

  testWidgets('reminds someone who has never exported', (tester) async {
    await seedRoom();
    await pump(tester);

    expect(find.text("You haven't backed up your data yet."), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('says how long it has been since the last export', (
    tester,
  ) async {
    await seedRoom();
    await pump(
      tester,
      prefs: {
        'backup.last_export_at': now
            .subtract(const Duration(days: 45))
            .toIso8601String(),
      },
    );

    expect(find.text('Your last backup was 45 days ago.'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('is snoozed when put off', (tester) async {
    await seedRoom();
    await pump(tester);

    await tester.tap(find.text('Not now'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialBanner), findsNothing);
    expect(
      containerOf(tester)
          .read(settingsRepositoryProvider)
          .backupReminderDismissedAt,
      now,
    );
    await unmount(tester);
  });

  testWidgets('exports, records when, and then goes away', (tester) async {
    await seedRoom();
    await pump(tester);

    await tester.tap(find.text('Export'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(files.saved, isNotEmpty);
    expect(
      containerOf(tester).read(settingsRepositoryProvider).lastExportAt,
      now,
    );
    expect(find.byType(MaterialBanner), findsNothing);
    await unmount(tester);
  });
}
