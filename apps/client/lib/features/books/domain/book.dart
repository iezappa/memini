import '../../../core/tracking/domain/trackable.dart';

/// A book the owner has finished reading.
class Book implements Trackable {
  const Book({
    required this.id,
    this.updatedAt,
    required this.title,
    required this.readOn,
    this.author,
    this.description,
    this.rating,
    this.review,
    this.publicationYear,
    this.externalId,
    this.coverUrl,
  });

  @override
  final String id;

  @override
  final DateTime? updatedAt;

  @override
  final String title;

  /// Day the book was finished.
  final DateTime readOn;

  @override
  DateTime get happenedOn => readOn;

  final String? author;

  @override
  final String? description;

  @override
  final double? rating;

  @override
  final String? review;

  final int? publicationYear;
  final String? externalId;
  final String? coverUrl;

  @override
  bool get isRated => rating != null;

  Book copyWith({
    String? title,
    DateTime? readOn,
    String? author,
    String? description,
    double? rating,
    String? review,
    int? publicationYear,
    String? externalId,
    String? coverUrl,
    bool clearRating = false,
    bool clearExternalId = false,
  }) {
    return Book(
      id: id,
      updatedAt: updatedAt,
      title: title ?? this.title,
      readOn: readOn ?? this.readOn,
      author: author ?? this.author,
      description: description ?? this.description,
      rating: clearRating ? null : (rating ?? this.rating),
      review: review ?? this.review,
      publicationYear: publicationYear ?? this.publicationYear,
      externalId: clearExternalId ? null : (externalId ?? this.externalId),
      coverUrl: clearExternalId ? null : (coverUrl ?? this.coverUrl),
    );
  }
}

class BookDraft {
  const BookDraft({
    required this.title,
    required this.readOn,
    this.author,
    this.description,
    this.rating,
    this.review,
    this.publicationYear,
    this.externalId,
    this.coverUrl,
  });

  final String title;
  final DateTime readOn;
  final String? author;
  final String? description;
  final double? rating;
  final String? review;
  final int? publicationYear;
  final String? externalId;
  final String? coverUrl;
}
