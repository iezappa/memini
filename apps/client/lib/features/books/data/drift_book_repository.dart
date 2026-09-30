import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/photos/data/photo_cascade.dart';
import '../../../core/tracking/data/tracking_query.dart';
import '../../../core/tracking/domain/tracking_filter.dart';
import '../domain/book.dart';
import '../domain/book_repository.dart';

class DriftBookRepository implements BookRepository {
  DriftBookRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  TrackingColumns get _columns {
    final books = _db.books;
    return TrackingColumns(
      id: books.id,
      title: books.title,
      description: books.description,
      review: books.review,
      rating: books.rating,
      happenedOn: books.happenedOn,
      extraSearch: [books.author],
    );
  }

  Book _toDomain(BookRow row) => Book(
    id: row.id,
    updatedAt: row.updatedAt,
    title: row.title,
    readOn: row.happenedOn,
    author: row.author,
    description: row.description,
    rating: row.rating,
    review: row.review,
    publicationYear: row.publicationYear,
    externalId: row.externalId,
    coverUrl: row.coverUrl,
  );

  SimpleSelectStatement<$BooksTable, BookRow> _query(BookFilter filter) {
    final query = _db.select(_db.books);

    final shared = trackingPredicate(_columns, filter);
    if (shared != null) query.where((_) => shared);

    final ordering = trackingOrdering(_columns, filter.sort);
    query.orderBy([for (final term in ordering) (_) => term]);
    return query;
  }

  @override
  Future<List<Book>> list(BookFilter filter) async =>
      (await _query(filter).get()).map(_toDomain).toList();

  @override
  Stream<List<Book>> watch(BookFilter filter) =>
      _query(filter).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Book?> findById(String id) async {
    final row = await (_db.select(
      _db.books,
    )..where((book) => book.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Book> create(BookDraft draft) async {
    final row = await _db
        .into(_db.books)
        .insertReturning(
          BooksCompanion.insert(
            updatedAt: _now(),
            title: draft.title.trim(),
            happenedOn: dayOf(draft.readOn),
            description: Value(draft.description),
            rating: Value(draft.rating),
            review: Value(draft.review),
            author: Value(draft.author),
            publicationYear: Value(draft.publicationYear),
            externalId: Value(draft.externalId),
            coverUrl: Value(draft.coverUrl),
          ),
        );
    return _toDomain(row);
  }

  @override
  Future<void> update(Book entry) async {
    await (_db.update(
      _db.books,
    )..where((book) => book.id.equals(entry.id))).write(
      BooksCompanion(
        updatedAt: Value(_now()),
        title: Value(entry.title.trim()),
        description: Value(entry.description),
        rating: Value(entry.rating),
        review: Value(entry.review),
        happenedOn: Value(dayOf(entry.readOn)),
        author: Value(entry.author),
        publicationYear: Value(entry.publicationYear),
        externalId: Value(entry.externalId),
        coverUrl: Value(entry.coverUrl),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.books)..where((book) => book.id.equals(id))).go();
      await _db.deletePhotosOf(id);
    });
  }
}
