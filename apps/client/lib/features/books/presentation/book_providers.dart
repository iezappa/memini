import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/clock.dart';
import '../../../core/tracking/presentation/tracking_filter_controller.dart';
import '../data/drift_book_repository.dart';
import '../domain/book.dart';
import '../domain/book_repository.dart';

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => DriftBookRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final bookFilterProvider = NotifierProvider<BookFilterController, BookFilter>(
  BookFilterController.new,
);

class BookFilterController extends TrackingFilterController<BookFilter> {
  @override
  BookFilter get pristine => const BookFilter();
}

final booksProvider = StreamProvider<List<Book>>((ref) {
  final filter = ref.watch(bookFilterProvider);
  return ref.watch(bookRepositoryProvider).watch(filter);
});

final allBooksProvider = StreamProvider<List<Book>>(
  (ref) => ref.watch(bookRepositoryProvider).watch(const BookFilter()),
);

final bookProvider = FutureProvider.family<Book?, String>((ref, id) {
  ref.watch(allBooksProvider);
  return ref.watch(bookRepositoryProvider).findById(id);
});
