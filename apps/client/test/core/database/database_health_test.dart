import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/database/database_health.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('memini_health_');
    file = File('${dir.path}/store.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  /// What IndexedDB can leave behind: every table on disk, and a
  /// `user_version` that never got written, so the next launch believes the
  /// store is brand new and creates it again.
  Future<void> leaveHalfCreated() async {
    final first = AppDatabase.forTesting(NativeDatabase(file));
    await first.customSelect('SELECT 1').get();
    await first
        .into(first.rooms)
        .insert(
          RoomsCompanion.insert(
            title: 'The Vault',
            happenedOn: DateTime(2026, 3, 14),
            escaped: true,
          ),
        );
    await first.customStatement('PRAGMA user_version = 0');
    await first.close();
  }

  group('a half-created store', () {
    test('opens, instead of failing to create what already exists', () async {
      await leaveHalfCreated();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      expect(await probeDatabase(db), isA<DatabaseHealthy>());
    });

    test('keeps the rows it already had', () async {
      await leaveHalfCreated();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      expect(await db.select(db.rooms).get(), hasLength(1));
    });
  });

  group('probeDatabase', () {
    test('reports a store that opens as healthy', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      expect(await probeDatabase(db), isA<DatabaseHealthy>());
    });

    test(
      'reports a store that cannot be opened, rather than throwing',
      () async {
        file.writeAsStringSync('this is not a sqlite database, not even close');

        final db = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(db.close);

        expect(await probeDatabase(db), isA<DatabaseUnopenable>());
      },
    );
  });
}
