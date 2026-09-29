import '../../../core/tracking/domain/tracking_filter.dart';
import '../../../core/tracking/domain/tracking_repository.dart';
import 'book.dart';

class BookFilter extends TrackingFilter {
  const BookFilter({super.query, super.minRating, super.sort});

  @override
  BookFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    bool clearQuery = false,
    bool clearMinRating = false,
  }) {
    return BookFilter(
      query: clearQuery ? null : (query ?? this.query),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
    );
  }
}

abstract interface class BookRepository
    implements TrackingRepository<Book, BookDraft, BookFilter> {}
