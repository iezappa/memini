import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/versioning/app_version.dart';
import 'package:memini/features/release_notes/domain/release_notes.dart';

void main() {
  String document(List<Map<String, Object?>> releases) =>
      jsonEncode({'releases': releases});

  Map<String, Object?> release(
    String version, {
    String date = '2026-09-01',
    List<Object?> highlights = const ['Something new'],
  }) => {'version': version, 'date': date, 'highlights': highlights};

  group('ReleaseNotes.parse', () {
    test('reads a release', () {
      final note = ReleaseNotes.parse(
        document([
          release('1.1.0', date: '2026-09-17', highlights: ['A', 'B']),
        ]),
      ).all.single;

      expect(note.version, const AppVersion(1, 1, 0));
      expect(note.date, DateTime(2026, 9, 17));
      expect(note.highlights, ['A', 'B']);
    });

    test('orders releases newest first, whatever the file says', () {
      final notes = ReleaseNotes.parse(
        document([release('1.0.0'), release('1.10.0'), release('1.9.0')]),
      );

      expect(notes.all.map((n) => '${n.version}'), [
        '1.10.0',
        '1.9.0',
        '1.0.0',
      ]);
      expect(notes.current, const AppVersion(1, 10, 0));
    });

    test('refuses what it cannot vouch for', () {
      for (final bad in [
        'not json',
        '[]',
        document([]),
        document([release('1.0.0'), release('1.0.0')]),
        document([release('1.0')]),
        document([release('1.0.0', highlights: [])]),
        document([
          release('1.0.0', highlights: ['  ']),
        ]),
        document([release('1.0.0', date: 'yesterday')]),
      ]) {
        expect(
          () => ReleaseNotes.parse(bad),
          throwsFormatException,
          reason: bad,
        );
      }
    });
  });

  group('what to announce', () {
    final notes = ReleaseNotes.parse(
      document([release('1.0.0'), release('1.1.0'), release('1.2.0')]),
    );

    test('a first install announces nothing', () {
      expect(notes.toAnnounce(lastSeen: null), isEmpty);
    });

    test('an upgrade announces every release newer than the last seen', () {
      expect(
        notes
            .toAnnounce(lastSeen: const AppVersion(1, 0, 0))
            .map((n) => '${n.version}'),
        ['1.2.0', '1.1.0'],
      );
    });

    test('the same version announces nothing', () {
      expect(notes.toAnnounce(lastSeen: const AppVersion(1, 2, 0)), isEmpty);
    });

    test('a downgrade announces nothing', () {
      expect(notes.toAnnounce(lastSeen: const AppVersion(9, 0, 0)), isEmpty);
    });
  });
}
