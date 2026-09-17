import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/versioning/app_version.dart';
import '../domain/update_service.dart';

/// Native builds: asks GitHub Releases for the latest version.
///
/// Unauthenticated, the API allows 60 requests an hour per IP, so a check
/// runs at most once every [throttle]. No token is ever embedded.
class GitHubUpdateService implements UpdateService {
  GitHubUpdateService({
    required this.client,
    required this.current,
    required this.now,
    required this.lastCheckedAt,
    required this.recordCheck,
    required this.isAndroid,
  });

  static final latestRelease = Uri.parse(
    'https://api.github.com/repos/iezappa/memini/releases/latest',
  );
  static const throttle = Duration(hours: 6);
  static const timeout = Duration(seconds: 5);

  final http.Client client;
  final Future<AppVersion> Function() current;
  final DateTime Function() now;
  final DateTime? Function() lastCheckedAt;
  final Future<void> Function(DateTime at) recordCheck;
  final bool isAndroid;

  @override
  Future<UpdateInfo?> check() async {
    final at = now();
    final last = lastCheckedAt();
    if (last != null && at.difference(last) < throttle) return null;

    try {
      await recordCheck(at);
      final response = await client
          .get(
            latestRelease,
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(timeout);
      if (response.statusCode != 200) return null;

      final release = jsonDecode(response.body);
      if (release is! Map<String, dynamic>) return null;
      final latest = AppVersion.tryParse(release['tag_name'] as String?);
      if (latest == null || !(latest > await current())) return null;

      final assets = [
        for (final asset in release['assets'] as List? ?? const [])
          if (asset is Map<String, dynamic>) asset,
      ];
      String? assetUrl(bool Function(String name) matches) {
        for (final asset in assets) {
          if (matches('${asset['name']}')) {
            return asset['browser_download_url'] as String?;
          }
        }
        return null;
      }

      final page = Uri.parse(release['html_url'] as String);
      final apk = isAndroid
          ? assetUrl((name) => name.endsWith('-android.apk'))
          : null;

      Object? updateJson;
      final updateUrl = assetUrl((name) => name == 'update.json');
      if (updateUrl != null) {
        try {
          final file = await client.get(Uri.parse(updateUrl)).timeout(timeout);
          if (file.statusCode == 200) updateJson = jsonDecode(file.body);
        } on Object {
          updateJson = null;
        }
      }
      final extra = readUpdateJson(updateJson);

      return UpdateInfo(
        latest: latest,
        url: apk == null ? page : Uri.parse(apk),
        notes: release['body'] as String?,
        schemaChange: extra.schemaChange,
        minSupportedVersion: extra.minSupportedVersion,
      );
    } on Object {
      return null;
    }
  }
}
