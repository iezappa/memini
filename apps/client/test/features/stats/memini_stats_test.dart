import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/tracking/domain/trackable.dart';
import 'package:memini/core/tracking/domain/tracked_domain.dart';
import 'package:memini/features/stats/domain/memini_stats.dart';

/// A minimal Trackable, so the aggregate is tested on its own terms rather
/// than through any one domain's extra fields.
class _Entry implements Trackable {
  const _Entry(this.title, this.rating, this.happenedOn);

  @override
  final String title;
  @override
  final double? rating;
  @override
  final DateTime happenedOn;

  @override
  int get id => title.hashCode;
  @override
  String? get photoPath => null;
  @override
  String? get description => null;
  @override
  String? get review => null;
  @override
  bool get isRated => rating != null;
}

Trackable entry(String title, {double? rating, int year = 2026}) =>
    _Entry(title, rating, DateTime(year, 6, 1));

void main() {
  group('MeminiStats.from', () {
    test('an empty log reports every domain at zero, not as missing', () {
      final stats = MeminiStats.from(const {});

      expect(stats.isEmpty, isTrue);
      expect(stats.total, 0);
      expect(stats.perDomain.keys, containsAll(TrackedDomain.values));
      expect(stats.perDomain.values.every((count) => count == 0), isTrue);
      expect(stats.best, isNull);
      expect(stats.averageRating, isNull);
    });

    test('counts each domain separately and totals them', () {
      final stats = MeminiStats.from({
        TrackedDomain.rooms: [entry('A')],
        TrackedDomain.dining: [entry('B'), entry('C')],
        TrackedDomain.games: [entry('D')],
      });

      expect(stats.perDomain[TrackedDomain.rooms], 1);
      expect(stats.perDomain[TrackedDomain.dining], 2);
      expect(stats.perDomain[TrackedDomain.games], 1);
      expect(stats.perDomain[TrackedDomain.concerts], 0);
      expect(stats.total, 4);
    });

    test('averages across domains, over rated entries only', () {
      final stats = MeminiStats.from({
        TrackedDomain.rooms: [entry('A', rating: 8)],
        TrackedDomain.dining: [entry('B', rating: 6), entry('C')],
      });

      expect(stats.rated, 2);
      expect(stats.averageRating, 7);
    });

    test('the best entry can come from any domain, and says which', () {
      final stats = MeminiStats.from({
        TrackedDomain.rooms: [entry('A room', rating: 8)],
        TrackedDomain.games: [entry('A game', rating: 9.5)],
        TrackedDomain.dining: [entry('A meal', rating: 9)],
      });

      expect(stats.best?.entry.title, 'A game');
      expect(stats.best?.domain, TrackedDomain.games);
    });

    test('an unrated entry never takes the top slot', () {
      final stats = MeminiStats.from({
        TrackedDomain.rooms: [entry('Unrated')],
        TrackedDomain.games: [entry('Rated badly', rating: 1)],
      });

      expect(stats.best?.entry.title, 'Rated badly');
    });

    test('a log with nothing rated has no best entry and no average', () {
      final stats = MeminiStats.from({
        TrackedDomain.rooms: [entry('A'), entry('B')],
      });

      expect(stats.total, 2);
      expect(stats.best, isNull);
      expect(stats.averageRating, isNull);
    });

    test('pools the years across every domain, newest first', () {
      final stats = MeminiStats.from({
        TrackedDomain.rooms: [entry('A', year: 2024)],
        TrackedDomain.dining: [entry('B', year: 2026), entry('C', year: 2024)],
        TrackedDomain.games: [entry('D', year: 2025)],
      });

      expect(stats.perYear.keys.toList(), [2026, 2025, 2024]);
      expect(stats.perYear[2024], 2);
    });
  });
}
