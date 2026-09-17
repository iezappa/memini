import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/ids/uuid.dart';
import 'package:memini/features/backup/domain/backup_document.dart';
import 'package:memini/features/backup/domain/entries_csv.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/domain/room.dart';

const franchiseId = '0f8fad5b-d9cb-469f-a165-70867728950e';
const roomId = '7c9e6679-7425-40de-944b-e07fc1f90ae7';

final franchise = Franchise(
  id: franchiseId,
  name: 'Enigma',
  updatedAt: DateTime.utc(2026, 9, 1, 12),
);

final room = Room(
  id: roomId,
  updatedAt: DateTime.utc(2026, 9, 2, 8, 30),
  title: 'The Vault',
  description: 'A bank heist',
  franchiseId: franchiseId,
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
      expect(restoredRoom.id, roomId);
      expect(restoredRoom.updatedAt, DateTime.utc(2026, 9, 2, 8, 30));
      expect(restoredRoom.franchiseId, franchiseId);
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

  group('format v3', () {
    test('is the version written today', () {
      expect(BackupDocument.currentVersion, 3);
      expect(
        BackupDocument.of(franchises: [], rooms: []).toJson()['version'],
        3,
      );
    });

    Map<String, dynamic> v3({
      List<Map<String, dynamic>> franchises = const [],
      List<Map<String, dynamic>> rooms = const [],
    }) => {
      'version': 3,
      'exportedAt': '2026-09-17T10:00:00.000Z',
      'franchises': franchises,
      'rooms': rooms,
    };

    Map<String, dynamic> roomJson({
      Object? id = roomId,
      Object? updatedAt = '2026-09-02T08:30:00.000Z',
      Object? franchise,
    }) => {
      'id': id,
      'title': 'The Vault',
      'happenedOn': '2026-03-14',
      'escaped': true,
      'updatedAt': updatedAt,
      'franchiseId': franchise,
    };

    test('refuses an id that is not a UUID', () {
      expect(
        () => BackupDocument.fromJson(v3(rooms: [roomJson(id: 7)])),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('refuses a record without updatedAt', () {
      expect(
        () => BackupDocument.fromJson(v3(rooms: [roomJson(updatedAt: null)])),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('refuses the same id twice', () {
      expect(
        () => BackupDocument.fromJson(v3(rooms: [roomJson(), roomJson()])),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('refuses a room linked to a franchise the file does not carry', () {
      expect(
        () => BackupDocument.fromJson(
          v3(rooms: [roomJson(franchise: franchiseId)]),
        ),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });

  group('importing a v2 file, with integer ids', () {
    Map<String, dynamic> v2() => {
      'version': 2,
      'exportedAt': '2026-08-01T10:00:00.000Z',
      'franchises': [
        {'id': 1, 'name': 'Enigma', 'logoPath': null},
        {'id': 2, 'name': 'Mystery'},
      ],
      'rooms': [
        {
          'id': 1,
          'title': 'The Vault',
          'photoPath': '/data/room_photos/1.jpg',
          'happenedOn': '2026-03-14',
          'escaped': true,
          'franchiseId': 2,
        },
        {
          'id': 2,
          'title': 'The Tomb',
          'happenedOn': '2026-03-15',
          'escaped': false,
          'franchiseId': 1,
        },
        {
          'id': 3,
          'title': 'Loose',
          'happenedOn': '2026-03-16',
          'escaped': false,
        },
      ],
      // The same integer as a room: ids were only unique per table.
      'meals': [
        {'id': 1, 'title': 'Don Julio', 'happenedOn': '2026-03-17'},
      ],
    };

    test('gives every record a fresh UUID', () {
      final doc = BackupDocument.fromJson(v2());
      final ids = [
        ...doc.franchises.map((f) => f.id),
        ...doc.rooms.map((r) => r.id),
        ...doc.meals.map((m) => m.id),
      ];

      for (final id in ids) {
        expect(id, matches(uuidV4Pattern));
      }
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('keeps every room linked to its own franchise', () {
      final doc = BackupDocument.fromJson(v2());
      final franchiseByName = {for (final f in doc.franchises) f.name: f.id};
      final roomByTitle = {for (final r in doc.rooms) r.title: r};

      expect(roomByTitle['The Vault']!.franchiseId, franchiseByName['Mystery']);
      expect(roomByTitle['The Tomb']!.franchiseId, franchiseByName['Enigma']);
      expect(roomByTitle['Loose']!.franchiseId, isNull);
    });

    test(
      'dates every record at the export, the latest it is known to hold',
      () {
        final doc = BackupDocument.fromJson(v2());

        expect(doc.rooms.first.updatedAt, DateTime.utc(2026, 8, 1, 10));
        expect(doc.franchises.first.updatedAt, DateTime.utc(2026, 8, 1, 10));
      },
    );

    test('still refuses a link to a franchise the file does not carry', () {
      final json = v2();
      (json['rooms'] as List).first['franchiseId'] = 99;

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('still refuses the same integer id twice in one table', () {
      final json = v2();
      (json['rooms'] as List)[1]['id'] = 1;

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('refuses a UUID where a v2 file had integers', () {
      final json = v2();
      (json['rooms'] as List).first['id'] = roomId;

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });
}
