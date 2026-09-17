import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memini/core/versioning/app_version.dart';
import 'package:memini/features/update/data/web_update_service.dart';

void main() {
  late List<Uri> requests;
  setUp(() => requests = []);

  WebUpdateService service({
    String version = '1.1.0',
    bool waiting = false,
    Object? updateJson,
    bool fail = false,
  }) {
    final client = MockClient((request) async {
      requests.add(request.url);
      if (fail) throw http.ClientException('offline');
      if (request.url.path.endsWith('version.json')) {
        return http.Response(
          jsonEncode({'app_name': 'memini', 'version': version}),
          200,
        );
      }
      if (updateJson == null) return http.Response('', 404);
      return http.Response(jsonEncode(updateJson), 200);
    });
    return WebUpdateService(
      client: client,
      base: Uri.parse('https://iezappa.github.io/memini/'),
      current: () async => const AppVersion(1, 1, 0),
      hasWaitingWorker: () async => waiting,
      now: () => DateTime.fromMillisecondsSinceEpoch(42),
    );
  }

  test('reads version.json under the base href, never from a cache', () async {
    await service().check();
    expect(
      requests.first,
      Uri.parse('https://iezappa.github.io/memini/version.json?t=42'),
    );
  });

  test('a newer version.json is an update', () async {
    final info = await service(version: '1.2.0').check();
    expect(info!.latest, const AppVersion(1, 2, 0));
  });

  test(
    'a waiting service worker is an update even at the same version',
    () async {
      expect(await service(waiting: true).check(), isNotNull);
    },
  );

  test('neither is no update', () async {
    expect(await service().check(), isNull);
  });

  test('schemaChange comes from update.json', () async {
    final info = await service(
      version: '1.2.0',
      updateJson: {'version': '1.2.0', 'schemaChange': true},
    ).check();
    expect(info!.schemaChange, isTrue);
  });

  test('offline is null, never an exception', () async {
    expect(await service(fail: true).check(), isNull);
  });
}
