import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/features/backup/domain/backup_document.dart';
import 'package:memini/features/backup/domain/entries_csv.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/domain/room.dart';

const franchise = Franchise(id: 1, name: 'Enigma');

final room = Room(
  id: 7,
  title: 'The Vault',
  description: 'A bank heist',
  franchiseId: 1,
  rating: 9.5,
  review: 'Best one yet',
  happenedOn: DateTime(2026, 3, 14),
  escaped: true,
  timeLeftMinutes: 4,
);

BackupDocument roundTrip(BackupDocument doc) =>
    BackupDocument.fromJson(jsonDecode(jsonEncode(doc.toJson())));

void main() {
  group('BackupDocument', () {
    test('survives a JSON round trip with every field intact', () {
      final restored = roundTrip(
        BackupDocument.of(franchises: [franchise], rooms: [room]),
      );

      expect(restored.version, BackupDocument.currentVersion);
      expect(restored.franchises.single, franchise);

      final restoredRoom = restored.rooms.single;
      expect(restoredRoom.id, 7);
      expect(restoredRoom.title, 'The Vault');
      expect(restoredRoom.rating, 9.5);
      expect(restoredRoom.review, 'Best one yet');
      expect(restoredRoom.happenedOn, DateTime(2026, 3, 14));
      expect(restoredRoom.escaped, isTrue);
      expect(restoredRoom.timeLeftMinutes, 4);
    });

    test('round trips an empty database', () {
      final restored = roundTrip(BackupDocument.of(franchises: [], rooms: []));

      expect(restored.rooms, isEmpty);
      expect(restored.franchises, isEmpty);
    });

    test('rejects a payload that is not an object', () {
      expect(
        () => BackupDocument.fromJson('nope'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects a document with no version', () {
      expect(
        () => BackupDocument.fromJson({'rooms': []}),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects a version newer than this build understands', () {
      final json = BackupDocument.of(franchises: [], rooms: []).toJson()
        ..['version'] = BackupDocument.currentVersion + 1;

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects a room pointing at a franchise the file does not carry', () {
      final json = BackupDocument.of(franchises: [], rooms: [room]).toJson();

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects a room with an out-of-range rating', () {
      final json = BackupDocument.of(franchises: [], rooms: []).toJson()
        ..['rooms'] = [
          {
            'id': 1,
            'name': 'Bad',
            'playedOn': '2026-01-01',
            'escaped': true,
            'rating': 11,
          },
        ];

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects a room with a blank name', () {
      final json = BackupDocument.of(franchises: [], rooms: []).toJson()
        ..['rooms'] = [
          {'id': 1, 'name': '  ', 'playedOn': '2026-01-01', 'escaped': true},
        ];

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });

  group('roomsToCsv', () {
    test('writes a header and one line per room', () {
      final csv = roomsToCsv(rooms: [room], franchises: [franchise]);
      final lines = const LineSplitter().convert(csv);

      expect(lines.first, startsWith('title,franchise,happened_on'));
      expect(lines, hasLength(2));
      expect(lines[1], contains('The Vault'));
      expect(lines[1], contains('Enigma'));
      expect(lines[1], contains('yes'));
    });

    test('quotes fields containing commas, quotes or newlines', () {
      final tricky = room.copyWith(review: 'He said "run", then we ran');

      final csv = roomsToCsv(rooms: [tricky], franchises: [franchise]);

      expect(csv, contains('"He said ""run"", then we ran"'));
    });

    test('leaves the franchise column blank for an unattached room', () {
      final loose = room.copyWith(clearFranchise: true);

      final csv = roomsToCsv(rooms: [loose], franchises: [franchise]);

      expect(const LineSplitter().convert(csv)[1], startsWith('The Vault,,'));
    });
  });
}
