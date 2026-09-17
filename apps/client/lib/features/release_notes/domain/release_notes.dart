import 'dart:convert';

import '../../../core/versioning/app_version.dart';

/// What one release brought, in the language its file is written in.
class ReleaseNote {
  const ReleaseNote({
    required this.version,
    required this.date,
    required this.highlights,
  });

  final AppVersion version;
  final DateTime date;
  final List<String> highlights;
}

/// The changelog bundled with the app, newest release first.
///
/// It ships inside the binary: with no server, the only moment someone can
/// learn what changed is when they run the version that carries it.
class ReleaseNotes {
  const ReleaseNotes._(this.all);

  /// Every rejection is a build-time mistake, so it throws; a test parses
  /// every bundled file so a typo fails the suite, not a launch.
  factory ReleaseNotes.parse(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('The release notes are not JSON: $error', source);
    }
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('The release notes are not an object', source);
    }
    final releases = decoded['releases'];
    if (releases is! List || releases.isEmpty) {
      throw FormatException('The release notes list no release', source);
    }

    final notes = releases.map(_note).toList()
      ..sort((a, b) => b.version.compareTo(a.version));

    final seen = <AppVersion>{};
    for (final note in notes) {
      if (!seen.add(note.version)) {
        throw FormatException('Version ${note.version} appears twice', source);
      }
    }
    return ReleaseNotes._(List.unmodifiable(notes));
  }

  static ReleaseNote _note(Object? entry) {
    if (entry is! Map<String, dynamic>) {
      throw FormatException('A release is not an object', '$entry');
    }
    final version = AppVersion.tryParse(entry['version'] as String?);
    if (version == null || '$version' != entry['version']) {
      throw FormatException('A release has no x.y.z version', '$entry');
    }
    final date = DateTime.tryParse('${entry['date']}');
    if (date == null) {
      throw FormatException('Release $version has no readable date', '$entry');
    }
    final highlights = entry['highlights'];
    if (highlights is! List || highlights.isEmpty) {
      throw FormatException('Release $version says nothing', '$entry');
    }
    final lines = <String>[
      for (final line in highlights)
        if (line is String && line.trim().isNotEmpty)
          line.trim()
        else
          throw FormatException('Release $version has a blank line', '$entry'),
    ];
    return ReleaseNote(
      version: version,
      date: DateTime(date.year, date.month, date.day),
      highlights: List.unmodifiable(lines),
    );
  }

  final List<ReleaseNote> all;

  /// The version this build is. A test pins it to pubspec.yaml.
  AppVersion get current => all.first.version;

  /// The releases to announce at launch.
  ///
  /// Nothing on a first install ([lastSeen] null): someone installing today
  /// was never around for the releases listed. Nothing on a downgrade either.
  List<ReleaseNote> toAnnounce({required AppVersion? lastSeen}) =>
      lastSeen == null
      ? const []
      : all.where((note) => note.version > lastSeen).toList();
}
