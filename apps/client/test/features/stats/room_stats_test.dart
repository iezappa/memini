import 'package:flutter_test/flutter_test.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/stats/domain/room_stats.dart';

Room room({
  int id = 1,
  String title = 'Room',
  double? rating,
  bool escaped = true,
  DateTime? happenedOn,
}) {
  return Room(
    id: id,
    title: title,
    happenedOn: happenedOn ?? DateTime(2026, 1, 1),
    escaped: escaped,
    rating: rating,
  );
}

void main() {
  group('RoomStats.from', () {
    test('returns the empty stats for no rooms', () {
      final stats = RoomStats.from([]);

      expect(stats.total, 0);
      expect(stats.escapeRate, isNull);
      expect(stats.averageRating, isNull);
      expect(stats.bestRoom, isNull);
      expect(stats.roomsPerYear, isEmpty);
    });

    test('counts escapes and failures', () {
      final stats = RoomStats.from([
        room(id: 1, escaped: true),
        room(id: 2, escaped: true),
        room(id: 3, escaped: false),
      ]);

      expect(stats.total, 3);
      expect(stats.escaped, 2);
      expect(stats.failed, 1);
      expect(stats.escapeRate, closeTo(2 / 3, 1e-9));
    });

    test('averages only rated rooms', () {
      final stats = RoomStats.from([
        room(id: 1, rating: 8),
        room(id: 2, rating: 6),
        room(id: 3),
      ]);

      expect(stats.rated, 2);
      expect(stats.averageRating, 7);
    });

    test('picks the highest rated room as best', () {
      final stats = RoomStats.from([
        room(id: 1, title: 'Good', rating: 7),
        room(id: 2, title: 'Best', rating: 9.5),
        room(id: 3, title: 'Unrated'),
      ]);

      expect(stats.bestRoom?.title, 'Best');
    });

    test('leaves best null when nothing is rated', () {
      final stats = RoomStats.from([room(id: 1), room(id: 2)]);

      expect(stats.bestRoom, isNull);
      expect(stats.averageRating, isNull);
    });

    test('groups rooms per year, newest first', () {
      final stats = RoomStats.from([
        room(id: 1, happenedOn: DateTime(2024, 5, 1)),
        room(id: 2, happenedOn: DateTime(2026, 2, 1)),
        room(id: 3, happenedOn: DateTime(2026, 8, 1)),
      ]);

      expect(stats.roomsPerYear.keys.toList(), [2026, 2024]);
      expect(stats.roomsPerYear[2026], 2);
      expect(stats.roomsPerYear[2024], 1);
    });
  });
}
