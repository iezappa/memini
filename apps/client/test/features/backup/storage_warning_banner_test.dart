import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/database/storage_durability.dart';
import 'package:memini/features/backup/presentation/backup_actions.dart';
import 'package:memini/features/backup/presentation/storage_warning_banner.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late FakeBackupFiles files;

  setUp(() {
    db = memoryDatabase();
    files = FakeBackupFiles();
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, StorageDurability durability) async {
    await tester.pumpWidget(
      await harness(
        const Scaffold(body: StorageWarningBanner()),
        database: db,
        overrides: [
          backupFilesProvider.overrideWithValue(files),
          storageDurabilityProvider.overrideWith((ref) => durability),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(Scaffold)));

  testWidgets('says nothing on storage that can be trusted', (tester) async {
    await pump(tester, StorageDurability.durable);

    expect(find.byType(MaterialBanner), findsNothing);
  });

  testWidgets('warns that IndexedDB can lose data', (tester) async {
    await pump(tester, StorageDurability.degraded);

    expect(find.textContaining('may be lost'), findsOneWidget);
    expect(find.text('Export now'), findsOneWidget);
  });

  testWidgets('warns harder when nothing is stored at all', (tester) async {
    await pump(tester, StorageDurability.volatile);

    expect(find.textContaining('will be lost when you close'), findsOneWidget);
  });

  testWidgets('exports from the banner itself', (tester) async {
    await pump(tester, StorageDurability.degraded);

    await tester.tap(find.text('Export now'));
    await tester.pumpAndSettle();

    expect(files.saved, isNotEmpty);
    await unmount(tester);
  });

  testWidgets('goes away for the session once dismissed', (tester) async {
    await pump(tester, StorageDurability.degraded);

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialBanner), findsNothing);
    expect(containerOf(tester).read(storageWarningDismissedProvider), isTrue);
  });
}
