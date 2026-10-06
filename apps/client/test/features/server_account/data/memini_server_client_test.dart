import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memini/features/backup/domain/backup_document.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/server_account/data/memini_server_client.dart';

void main() {
  test('logs in against the configured server', () async {
    final client = MeminiServerClient(
      baseUrl: 'http://server.local:5053',
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'http://server.local:5053/api/auth/login',
        );
        expect(jsonDecode(request.body), {
          'username': 'admin',
          'password': 'secret123',
        });
        return http.Response(
          jsonEncode({
            'token': 'abc',
            'user': {'id': 'u1', 'username': 'admin', 'isAdmin': true},
          }),
          200,
        );
      }),
    );

    final result = await client.login(username: 'admin', password: 'secret123');

    expect(result.token, 'abc');
    expect(result.user.username, 'admin');
    expect(result.user.isAdmin, isTrue);
  });

  test('creates a family user with admin bearer auth', () async {
    final client = MeminiServerClient(
      baseUrl: 'http://server.local:5053',
      client: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer admin-token');
        expect(request.url.path, '/api/admin/users');
        expect(jsonDecode(request.body), {
          'username': 'maria',
          'password': 'family pass',
        });
        return http.Response(
          jsonEncode({'id': 'u2', 'username': 'maria', 'isAdmin': false}),
          201,
        );
      }),
    );

    final user = await client.createUser(
      token: 'admin-token',
      username: 'maria',
      password: 'family pass',
    );

    expect(user.username, 'maria');
    expect(user.isAdmin, isFalse);
  });

  test('surfaces server validation errors when creating a user', () async {
    final client = MeminiServerClient(
      baseUrl: 'http://server.local:5053',
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'password must be at least 8 characters'}),
          400,
        );
      }),
    );

    await expectLater(
      client.createUser(
        token: 'admin-token',
        username: 'maria',
        password: 'short',
      ),
      throwsA(
        isA<ServerAccountException>().having(
          (error) => error.message,
          'message',
          'password must be at least 8 characters',
        ),
      ),
    );
  });

  test('adds http when the server URL has no scheme', () async {
    final client = MeminiServerClient(
      baseUrl: 'zima.local:5053',
      client: MockClient((request) async {
        expect(request.url.toString(), 'http://zima.local:5053/healthz');
        return http.Response('{"ok":true}', 200);
      }),
    );

    await client.healthCheck();
  });

  test('uploads the backup document with bearer auth', () async {
    final client = MeminiServerClient(
      baseUrl: 'http://server.local:5053',
      client: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer token');
        expect(request.url.path, '/api/backup/import');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['version'], BackupDocument.currentVersion);
        expect(body['rooms'], isA<List>());
        return http.Response(jsonEncode({'rowCount': 1}), 200);
      }),
    );

    final result = await client.uploadBackup(
      token: 'token',
      document: _backup(),
    );

    expect(result.rowCount, 1);
  });

  test('downloads a Memini backup document', () async {
    final client = MeminiServerClient(
      baseUrl: 'http://server.local:5053',
      client: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer token');
        expect(request.url.path, '/api/backup/export');
        return http.Response(jsonEncode(_backup().toJson()), 200);
      }),
    );

    final document = await client.downloadBackup(token: 'token');

    expect(document.entryCount, 1);
    expect(document.rooms.single.title, 'Room one');
  });
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
