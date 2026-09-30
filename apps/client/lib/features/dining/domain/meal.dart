import '../../../core/tracking/domain/trackable.dart';

/// A place the owner has eaten at, on one particular visit.
///
/// The entry is the visit, not the restaurant: going back to the same place
/// twice is two meals, because the dish and the verdict can differ.
class Meal implements Trackable {
  const Meal({
    required this.id,
    this.updatedAt,
    required this.title,
    required this.happenedOn,
    this.description,
    this.rating,
    this.review,
    this.dish,
    this.price,
    this.company,
    this.mapsUrl,
  });

  @override
  final String id;

  @override
  final DateTime? updatedAt;

  /// Name of the place.
  @override
  final String title;
  @override
  final String? description;
  @override
  final double? rating;
  @override
  final String? review;
  @override
  final DateTime happenedOn;

  /// What was actually ordered.
  final String? dish;

  /// What the visit cost, in whatever currency the owner keeps. Deliberately
  /// untyped as money: this is a personal log, not an accounting ledger.
  final double? price;

  /// Who came along.
  final String? company;

  /// A link to the place on a map, as the owner pasted it.
  final String? mapsUrl;

  @override
  bool get isRated => rating != null;

  Meal copyWith({
    String? title,
    String? description,
    double? rating,
    String? review,
    DateTime? happenedOn,
    String? dish,
    double? price,
    String? company,
    String? mapsUrl,
    bool clearRating = false,
    bool clearPrice = false,
  }) {
    return Meal(
      id: id,
      updatedAt: updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: clearRating ? null : (rating ?? this.rating),
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      dish: dish ?? this.dish,
      price: clearPrice ? null : (price ?? this.price),
      company: company ?? this.company,
      mapsUrl: mapsUrl ?? this.mapsUrl,
    );
  }
}

/// Input for creating a meal, before the store assigns an id.
class MealDraft {
  const MealDraft({
    required this.title,
    required this.happenedOn,
    this.description,
    this.rating,
    this.review,
    this.dish,
    this.price,
    this.company,
    this.mapsUrl,
  });

  final String title;
  final DateTime happenedOn;
  final String? description;
  final double? rating;
  final String? review;
  final String? dish;
  final double? price;
  final String? company;

  /// A link to the place on a map, as pasted.
  final String? mapsUrl;
}
