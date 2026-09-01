import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/tracking/domain/tracking_filter.dart';

void main() {
  group('TrackingFilter', () {
    test('is empty when nothing narrows the list, whatever the sort', () {
      expect(const TrackingFilter().isEmpty, isTrue);
      expect(
        const TrackingFilter(sort: TrackingSort.titleAsc).isEmpty,
        isTrue,
        reason: 'ordering changes the view, it does not narrow it',
      );
      expect(const TrackingFilter(query: 'a').isEmpty, isFalse);
      expect(const TrackingFilter(minRating: 7).isEmpty, isFalse);
    });

    test('copyWith replaces only the fields it is given', () {
      const filter = TrackingFilter(query: 'noir', minRating: 6);

      final sorted = filter.copyWith(sort: TrackingSort.ratingDesc);

      expect(sorted.query, 'noir');
      expect(sorted.minRating, 6);
      expect(sorted.sort, TrackingSort.ratingDesc);
    });

    test('clear flags remove a field, which copyWith alone cannot express', () {
      const filter = TrackingFilter(query: 'noir', minRating: 6);

      expect(filter.copyWith(clearQuery: true).query, isNull);
      expect(filter.copyWith(clearQuery: true).minRating, 6);
      expect(filter.copyWith(clearMinRating: true).minRating, isNull);
    });

    test('a blank or whitespace-only query does not narrow the list', () {
      expect(const TrackingFilter(query: '   ').isEmpty, isTrue);
      expect(const TrackingFilter(query: '').isEmpty, isTrue);
    });

    test('exposes the trimmed search term, or null when there is none', () {
      expect(const TrackingFilter(query: '  noir  ').searchTerm, 'noir');
      expect(const TrackingFilter(query: '   ').searchTerm, isNull);
      expect(const TrackingFilter().searchTerm, isNull);
    });
  });

  group('dayOf', () {
    test('drops the time part so same-day entries never sort by chance', () {
      expect(dayOf(DateTime(2025, 3, 9, 23, 41, 12)), DateTime(2025, 3, 9));
    });
  });
}
