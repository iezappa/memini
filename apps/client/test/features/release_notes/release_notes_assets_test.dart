import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/versioning/app_version.dart';
import 'package:memini/features/release_notes/data/asset_release_notes.dart';
import 'package:memini/features/release_notes/domain/release_notes.dart';

/// The notes are hand-written and ship inside the app: a typo or a forgotten
/// release fails here instead of greeting a user with an empty dialog.
void main() {
  ReleaseNotes read(String language) => ReleaseNotes.parse(
    File(AssetReleaseNotes.pathFor(language)).readAsStringSync(),
  );

  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('every shipped language parses', () {
    for (final language in AssetReleaseNotes.supportedLanguages) {
      expect(read(language).all, isNotEmpty, reason: language);
    }
  });

  test('the pubspec version has notes in every language', () {
    final declared = AppVersion.tryParse(
      RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec)![1],
    );
    expect(declared, isNotNull);

    for (final language in AssetReleaseNotes.supportedLanguages) {
      expect(
        read(language).current,
        declared,
        reason: 'the newest $language release must be the pubspec version',
      );
    }
  });

  test('every language lists the same releases on the same days', () {
    final histories = {
      for (final language in AssetReleaseNotes.supportedLanguages)
        [
          for (final note in read(language).all)
            '${note.version} ${note.date.toIso8601String()}',
        ].join(', '),
    };

    expect(histories, hasLength(1), reason: '$histories');
  });

  test('the notes are declared as an asset, so they ship', () {
    expect(pubspec, contains('- assets/release_notes/'));
  });

  test('web/update.json announces the pubspec version', () {
    // release.yml refuses a tag whose update.json disagrees; failing here
    // catches it before a tag is pushed.
    final update = jsonDecode(File('web/update.json').readAsStringSync());
    final declared = AppVersion.tryParse(
      RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec)![1],
    );
    expect(AppVersion.tryParse(update['version'] as String), declared);
    expect(update['schemaChange'], isA<bool>());
  });
}
