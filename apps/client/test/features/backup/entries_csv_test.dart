import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/features/backup/domain/entries_csv.dart';
import 'package:memini/features/concerts/domain/gig.dart';

void main() {
  group('gigsToCsv', () {
    test('exports optional album and YouTube links', () {
      final csv = gigsToCsv([
        Gig(
          id: 'gig-1',
          title: 'Radiohead',
          happenedOn: DateTime(2026, 3, 14),
          photosUrl: 'https://photos.example/radiohead',
          videoUrl: 'https://youtu.be/abc123',
        ),
      ]);
      final lines = const LineSplitter().convert(csv);

      expect(lines.first, contains('photos_url'));
      expect(lines.first, contains('video_url'));
      expect(
        lines.singleWhere((line) => line.startsWith('Radiohead')),
        contains('https://photos.example/radiohead'),
      );
      expect(
        lines.singleWhere((line) => line.startsWith('Radiohead')),
        contains('https://youtu.be/abc123'),
      );
    });
  });
}
