import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memini/core/versioning/app_version.dart';
import 'package:memini/features/update/data/github_update_service.dart';

void main() {
  late DateTime now;
  DateTime? lastCheck;
  late List<Uri> requests;

  setUp(() {
    now = DateTime(2026, 9, 17, 12);
    lastCheck = null;
    requests = [];
  });

  Map<String, Object?> release({
    String tag = 'v1.2.0',
    bool withUpdateJson = true,
  }) => {
    'tag_name': tag,
    'html_url': 'https://github.com/iezappa/memini/releases/tag/$tag',
    'body': 'Notes',
    'assets': [
      {
        'name': 'memini-$tag-android.apk',
        'browser_download_url': 'https://example.test/memini-$tag-android.apk',
      },
      if (withUpdateJson)
        {
          'name': 'update.json',
          'browser_download_url': 'https://example.test/update.json',
        },
    ],
  };

  GitHubUpdateService service({
    Map<String, Object?>? latest,
    Object? updateJson,
    bool fail = false,
    bool android = false,
  }) {
    final client = MockClient((request) async {
      requests.add(request.url);
      if (fail) throw http.ClientException('offline');
      if (request.url.host == 'api.github.com') {
        expect(request.headers['Accept'], 'application/vnd.github+json');
        return http.Response(jsonEncode(latest ?? release()), 200);
      }
      if (updateJson == null) return http.Response('', 404);
      return http.Response(jsonEncode(updateJson), 200);
    });
    return GitHubUpdateService(
      client: client,
      current: () async => const AppVersion(1, 1, 0),
      now: () => now,
      lastCheckedAt: () => lastCheck,
      recordCheck: (at) async => lastCheck = at,
      isAndroid: android,
    );
  }

  test('asks the latest release of the Memini repository', () async {
    await service().check();
    expect(
      requests.first,
      Uri.parse('https://api.github.com/repos/iezappa/memini/releases/latest'),
    );
  });

  group('throttle', () {
    test('never checked: checks, and remembers when', () async {
      expect(await service().check(), isNotNull);
      expect(lastCheck, now);
    });

    test('checked 5 hours ago: does not ask', () async {
      lastCheck = now.subtract(const Duration(hours: 5));
      expect(await service().check(), isNull);
      expect(requests, isEmpty);
    });

    test('checked 7 hours ago: asks again', () async {
      lastCheck = now.subtract(const Duration(hours: 7));
      expect(await service().check(), isNotNull);
    });
  });

  test('a newer release on desktop points at the release page', () async {
    final info = await service().check();
    expect(info!.latest, const AppVersion(1, 2, 0));
    expect(
      info.url,
      Uri.parse('https://github.com/iezappa/memini/releases/tag/v1.2.0'),
    );
    expect(info.schemaChange, isFalse);
  });

  test('on Android it points at the APK', () async {
    final info = await service(android: true).check();
    expect(
      info!.url,
      Uri.parse('https://example.test/memini-v1.2.0-android.apk'),
    );
  });

  test('on Android without an APK attached yet, the release page', () async {
    final latest = release()..['assets'] = const [];
    final info = await service(android: true, latest: latest).check();
    expect(info!.url.path, '/iezappa/memini/releases/tag/v1.2.0');
  });

  test('reads schemaChange and minSupportedVersion from update.json', () async {
    final info = await service(
      updateJson: {
        'version': '1.2.0',
        'schemaChange': true,
        'minSupportedVersion': '1.0.0',
      },
    ).check();
    expect(info!.schemaChange, isTrue);
    expect(info.minSupportedVersion, const AppVersion(1, 0, 0));
  });

  test('the same or an older version is no update', () async {
    expect(await service(latest: release(tag: 'v1.1.0')).check(), isNull);
    lastCheck = null;
    expect(await service(latest: release(tag: 'v1.0.9')).check(), isNull);
  });

  test('a network error is null, never an exception', () async {
    expect(await service(fail: true).check(), isNull);
  });

  test('a garbage tag is null', () async {
    expect(await service(latest: release(tag: 'nightly')).check(), isNull);
  });
}
