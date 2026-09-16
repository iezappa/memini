import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/app/app_restart.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/database/database_health.dart';
import 'package:memini/core/database/local_store.dart';
import 'package:memini/features/backup/data/backup_service.dart';
import 'package:memini/features/backup/presentation/backup_actions.dart';
import 'package:memini/features/backup/presentation/database_gate.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/l10n/app_localizations.dart';

import '../../support/harness.dart';

void main() {
  late Directory dir;
  late File file;
  late FakeBackupFiles files;
  late int restarts;
  late ProviderContainer container;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('memini_recovery_');
    file = File('${dir.path}/store.sqlite')
      ..writeAsStringSync('not a database, and never was');
    files = FakeBackupFiles();
    restarts = 0;
    container = ProviderContainer(
      overrides: [
        // A factory, not a value: recovery throws the broken connection away
        // and needs a new one on the same file.
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase.forTesting(NativeDatabase(file));
          ref.onDispose(db.close);
          return db;
        }),
        eraseLocalStoreProvider.overrideWithValue(() async {
          if (file.existsSync()) file.deleteSync();
        }),
        backupFilesProvider.overrideWithValue(files),
        restartAppProvider.overrideWithValue(() => restarts++),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    dir.deleteSync(recursive: true);
  });

  Future<Uint8List> backupWithOneRoom() async {
    final source = memoryDatabase();
    addTearDown(source.close);
    await DriftRoomRepository(source).create(
      RoomDraft(
        title: 'The Vault',
        happenedOn: DateTime(2026, 3, 14),
        escaped: true,
      ),
    );
    return utf8.encode(await BackupService(source).exportJson());
  }

  group('DatabaseRecoveryActions', () {
    test('reset throws the broken store away and restarts the app', () async {
      await container.read(databaseRecoveryActionsProvider).reset();

      expect(file.existsSync(), isFalse);
      expect(restarts, 1);
    });

    test('import restores the backup into a fresh store', () async {
      files.toOpen = await backupWithOneRoom();

      final outcome = await container
          .read(databaseRecoveryActionsProvider)
          .importBackup();

      expect(outcome, RestoreOutcome.restored);
      expect(restarts, 1);
      final db = container.read(databaseProvider);
      expect(await probeDatabase(db), isA<DatabaseHealthy>());
      expect(await db.select(db.rooms).get(), hasLength(1));
    });

    test('import touches nothing when the file is not a backup', () async {
      files.toOpen = utf8.encode('dear diary');

      final outcome = await container
          .read(databaseRecoveryActionsProvider)
          .importBackup();

      expect(outcome, RestoreOutcome.rejected);
      expect(file.existsSync(), isTrue);
      expect(restarts, 0);
    });

    test('import touches nothing when the user backs out', () async {
      final outcome = await container
          .read(databaseRecoveryActionsProvider)
          .importBackup();

      expect(outcome, RestoreOutcome.cancelled);
      expect(file.existsSync(), isTrue);
    });
  });

  group('DatabaseGate', () {
    Future<void> pump(WidgetTester tester, DatabaseHealth health) async {
      final gated = ProviderContainer(
        parent: container,
        overrides: [databaseHealthProvider.overrideWith((ref) async => health)],
      );
      addTearDown(gated.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: gated,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Pinned: these assertions read the English copy.
            locale: const Locale('en'),
            builder: (context, child) =>
                DatabaseGate(child: child ?? const SizedBox()),
            home: const Scaffold(body: Text('the app')),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('lets a healthy store through to the app', (tester) async {
      await pump(tester, const DatabaseHealthy());

      expect(find.text('the app'), findsOneWidget);
    });

    testWidgets('shows recovery instead of an app that cannot read', (
      tester,
    ) async {
      await pump(tester, DatabaseUnopenable(Exception('boom')));

      expect(find.text('the app'), findsNothing);
      expect(find.text('Import a backup'), findsOneWidget);
      expect(find.text('Reset local database'), findsOneWidget);
    });

    testWidgets('asks before resetting, and says the data goes', (
      tester,
    ) async {
      await pump(tester, DatabaseUnopenable(Exception('boom')));

      await tester.tap(find.text('Reset local database'));
      await tester.pumpAndSettle();

      expect(find.textContaining('permanently deleted'), findsOneWidget);
      expect(file.existsSync(), isTrue);
      expect(restarts, 0);
    });

    testWidgets('resets once confirmed', (tester) async {
      await pump(tester, DatabaseUnopenable(Exception('boom')));

      await tester.tap(find.text('Reset local database'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(restarts, 1);
    });
  });
}
