import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/domain/tracking_filter.dart';
import 'package:memini/features/books/data/drift_book_repository.dart';
import 'package:memini/features/books/domain/book.dart';
import 'package:memini/features/books/domain/book_repository.dart';

void main() {
  late AppDatabase db;
  late DriftBookRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftBookRepository(db);
  });

  tearDown(() => db.close());

  Future<Book> add({
    String title = 'Kindred',
    String? author = 'Octavia E. Butler',
    double? rating,
    DateTime? readOn,
    String? description,
    String? review,
  }) {
    return repository.create(
      BookDraft(
        title: title,
        author: author,
        readOn: readOn ?? DateTime(2026, 1, 1),
        rating: rating,
        description: description,
        review: review,
      ),
    );
  }

  Future<List<String>> titles(BookFilter filter) async =>
      (await repository.list(filter)).map((book) => book.title).toList();

  test('creates a completed book and reads every field back', () async {
    final created = await repository.create(
      BookDraft(
        title: 'Kindred',
        author: 'Octavia E. Butler',
        readOn: DateTime(2026, 3, 14, 20),
        description: 'A time travel novel',
        rating: 9,
        review: 'Still sharp',
        publicationYear: 1979,
        externalId: '/works/OL123W',
        coverUrl: 'https://covers.openlibrary.org/b/id/12345-L.jpg',
      ),
    );

    final reloaded = await repository.findById(created.id);

    expect(reloaded!.title, 'Kindred');
    expect(reloaded.author, 'Octavia E. Butler');
    expect(reloaded.publicationYear, 1979);
    expect(reloaded.externalId, '/works/OL123W');
    expect(reloaded.coverUrl, contains('12345'));
    expect(reloaded.readOn, DateTime(2026, 3, 14));
    expect(reloaded.happenedOn, DateTime(2026, 3, 14));
  });

  test('inherits the shared search and ordering', () async {
    await add(title: 'Kindred', author: 'Octavia Butler', rating: 9);
    await add(title: 'Parable', description: 'A Butler novel', rating: 10);
    await add(title: 'Unrelated', author: null, rating: 8);

    final result = await titles(
      const BookFilter(query: 'butler', sort: TrackingSort.ratingDesc),
    );

    expect(result, ['Parable', 'Kindred']);
  });

  test('deletes a book', () async {
    final created = await add();
    await repository.delete(created.id);
    expect(await repository.findById(created.id), isNull);
  });
}
