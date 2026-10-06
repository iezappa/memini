import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/features/backup/domain/backup_document.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/server_account/data/memini_server_client.dart';
import 'package:memini/features/server_account/domain/backup_fingerprint.dart';
import 'package:memini/features/server_account/presentation/server_account_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists the automatic backup switch', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    container.read(serverAutoBackupEnabledProvider.notifier).set(true);

    expect(container.read(serverAutoBackupEnabledProvider), isTrue);
    expect(prefs.getBool(ServerAutoBackupEnabledController.key), isTrue);
  });

  test(
    'automatic backup uploads once and records a clean fingerprint',
    () async {
      final document = _backup();
      var uploadCount = 0;
      final container = await _container(
        autoBackupEnabled: true,
        backupReader: () async => document,
        client: (baseUrl) => MeminiServerClient(
          baseUrl: baseUrl,
          client: MockClient((request) async {
            uploadCount++;
            expect(request.headers['authorization'], 'Bearer token');
            expect(request.url.path, '/api/backup/import');
            expect(jsonDecode(request.body)['exportedAt'], isA<String>());
            return http.Response(jsonEncode({'rowCount': 1}), 200);
          }),
        ),
      );
      addTearDown(container.dispose);

      final outcome = await container
          .read(serverAccountActionsProvider)
          .runAutomaticBackup();

      expect(outcome, isA<ServerBackupSucceeded>());
      expect(uploadCount, 1);
      expect(
        container.read(serverLastAutoBackupFingerprintProvider),
        backupDocumentFingerprint(document),
      );
      expect(
        container.read(serverLastAutoBackupSucceededAtProvider),
        isNotEmpty,
      );
    },
  );

  test('automatic backup skips unchanged content', () async {
    final document = _backup();
    final container = await _container(
      autoBackupEnabled: true,
      lastFingerprint: backupDocumentFingerprint(document),
      backupReader: () async => document,
      client: (baseUrl) => MeminiServerClient(
        baseUrl: baseUrl,
        client: MockClient((request) async {
          fail('unchanged content should not upload');
        }),
      ),
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(serverAccountActionsProvider)
        .runAutomaticBackup();

    expect(outcome, isNull);
  });

  test('automatic backup failure does not mark the document clean', () async {
    final document = _backup();
    final container = await _container(
      autoBackupEnabled: true,
      backupReader: () async => document,
      client: (baseUrl) => MeminiServerClient(
        baseUrl: baseUrl,
        client: MockClient((request) async => http.Response('nope', 500)),
      ),
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(serverAccountActionsProvider)
        .runAutomaticBackup();

    expect(outcome, isA<ServerBackupFailed>());
    expect(container.read(serverLastAutoBackupFingerprintProvider), isEmpty);
    expect(container.read(serverLastAutoBackupSucceededAtProvider), isEmpty);
  });
}

Future<ProviderContainer> _container({
  required bool autoBackupEnabled,
  required Future<BackupDocument> Function() backupReader,
  required MeminiServerClient Function(String) client,
  String lastFingerprint = '',
}) async {
  SharedPreferences.setMockInitialValues({
    'serverAccount.baseUrl': 'http://server.local:5053',
    'serverAccount.username': 'owner',
    'serverAccount.token': 'token',
    'serverAccount.isAdmin': false,
    ServerAutoBackupEnabledController.key: autoBackupEnabled,
    'serverAccount.lastAutoBackupFingerprint': lastFingerprint,
  });
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      localBackupReaderProvider.overrideWithValue(backupReader),
      meminiServerClientFactoryProvider.overrideWithValue(client),
    ],
  );
}

BackupDocument _backup() => BackupDocument.of(
  franchises: const [],
  rooms: [
    Room(
      id: '123e4567-e89b-42d3-a456-426614174000',
      updatedAt: DateTime(2026, 1, 1),
      title: 'Room one',
      happenedOn: DateTime(2026, 1, 1),
      escaped: true,
    ),
  ],
  exportedAt: DateTime(2026, 1, 1),
);
