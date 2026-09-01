import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/tracking/domain/trackable.dart';
import 'package:memini/core/tracking/domain/tracking_stats.dart';

/// A minimal Trackable so the shared stats are tested on their own terms,
/// not through any one domain's extra fields.
class _Entry implements Trackable {
  const _Entry(this.id, this.title, this.rating, this.happenedOn);

  @override
  final int id;
  @override
  final String title;
  @override
  final double? rating;
  @override
  final DateTime happenedOn;

  @override
  String? get photoPath => null;
  @override
  String? get description => null;
  @override
  String? get review => null;
  @override
  bool get isRated => rating != null;
}

Trackable entry(String title, {double? rating, required int year}) =>
    _Entry(title.hashCode, title, rating, DateTime(year, 6, 15));

void main() {
  group('TrackingStats.from', () {
    test('an empty list yields the empty stats', () {
      final stats = TrackingStats<_Entry>.from(const []);

      expect(stats.total, 0);
      expect(stats.rated, 0);
      expect(stats.averageRating, isNull);
      expect(stats.best, isNull);
      expect(stats.perYear, isEmpty);
    });

    test('averages over rated entries only, ignoring unrated ones', () {
      final stats = TrackingStats.from([
        entry('a', rating: 8, year: 2024),
        entry('b', rating: 6, year: 2024),
        entry('c', year: 2024),
      ]);

      expect(stats.total, 3);
      expect(stats.rated, 2);
      expect(stats.averageRating, 7);
    });

    test('picks the highest rated entry as the best one', () {
      final stats = TrackingStats.from([
        entry('a', rating: 4, year: 2023),
        entry('b', rating: 9.5, year: 2024),
        entry('c', rating: 9, year: 2024),
      ]);

      expect(stats.best?.title, 'b');
    });

    test('an entirely unrated list has no best entry', () {
      final stats = TrackingStats.from([
        entry('a', year: 2024),
        entry('b', year: 2023),
      ]);

      expect(stats.total, 2);
      expect(stats.averageRating, isNull);
      expect(stats.best, isNull);
    });

    test('counts entries per calendar year, newest year first', () {
      final stats = TrackingStats.from([
        entry('a', year: 2023),
        entry('b', year: 2025),
        entry('c', year: 2023),
        entry('d', year: 2024),
      ]);

      expect(stats.perYear.keys.toList(), [2025, 2024, 2023]);
      expect(stats.perYear[2023], 2);
      expect(stats.perYear[2024], 1);
      expect(stats.perYear[2025], 1);
    });
  });
}
