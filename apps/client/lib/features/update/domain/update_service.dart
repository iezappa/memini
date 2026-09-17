import '../../../core/versioning/app_version.dart';

/// A newer release than the one running (STACK-APPS-DINAMICAS.md 8.2).
class UpdateInfo {
  const UpdateInfo({
    required this.latest,
    required this.url,
    this.notes,
    this.schemaChange = false,
    this.minSupportedVersion,
  });

  final AppVersion latest;

  /// The APK, the release page, or the app itself on the web.
  final Uri url;
  final String? notes;

  /// The release changes the local database: recommend a backup first.
  final bool schemaChange;

  /// The oldest version the migration is tested from.
  final AppVersion? minSupportedVersion;
}

abstract interface class UpdateService {
  /// Null when there is nothing newer, no network, or the throttle says wait.
  /// Never throws: being offline is a normal case, not an error.
  Future<UpdateInfo?> check();
}

/// Reads the `update.json` convention; anything unreadable is "no schema
/// change", which is what a release without the file means too.
({bool schemaChange, AppVersion? minSupportedVersion}) readUpdateJson(
  Object? json,
) {
  if (json is! Map<String, dynamic>) {
    return (schemaChange: false, minSupportedVersion: null);
  }
  return (
    schemaChange: json['schemaChange'] == true,
    minSupportedVersion: AppVersion.tryParse(
      json['minSupportedVersion'] as String?,
    ),
  );
}
