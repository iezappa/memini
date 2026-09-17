import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/versioning/app_version.dart';
import '../domain/update_service.dart';

/// The web build: compares `version.json` from its own site, and asks the
/// service worker whether a new version is installed and waiting.
///
/// Same origin, so no rate limit and no throttle.
class WebUpdateService implements UpdateService {
  WebUpdateService({
    required this.client,
    required this.base,
    required this.current,
    required this.hasWaitingWorker,
    required this.now,
  });

  final http.Client client;
  final Uri base;
  final Future<AppVersion> Function() current;
  final Future<bool> Function() hasWaitingWorker;
  final DateTime Function() now;

  Future<Object?> _json(String name) async {
    final url = base
        .resolve(name)
        .replace(queryParameters: {'t': '${now().millisecondsSinceEpoch}'});
    final response = await client.get(url).timeout(const Duration(seconds: 5));
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  @override
  Future<UpdateInfo?> check() async {
    try {
      final running = await current();
      final published = await _json('version.json');
      final remote = published is Map<String, dynamic>
          ? AppVersion.tryParse(published['version'] as String?)
          : null;

      final newer = remote != null && remote > running;
      final waiting = await hasWaitingWorker();
      if (!newer && !waiting) return null;

      Object? updateJson;
      try {
        updateJson = await _json('update.json');
      } on Object {
        updateJson = null;
      }
      final extra = readUpdateJson(updateJson);

      return UpdateInfo(
        latest: newer ? remote : running,
        url: base,
        schemaChange: extra.schemaChange,
        minSupportedVersion: extra.minSupportedVersion,
      );
    } on Object {
      return null;
    }
  }
}
