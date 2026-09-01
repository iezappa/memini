import '../../../core/tracking/domain/trackable.dart';

/// A place the owner has eaten at, on one particular visit.
///
/// The entry is the visit, not the restaurant: going back to the same place
/// twice is two meals, because the dish and the verdict can differ.
class Meal implements Trackable {
  const Meal({
    required this.id,
    required this.title,
    required this.happenedOn,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    this.dish,
    this.price,
    this.company,
    this.location,
  });

  @override
  final int id;

  /// Name of the place.
  @override
  final String title;
  @override
  final String? photoPath;
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

  /// Neighbourhood, city or address — free text, since no free places API
  /// covers this well enough to structure it.
  final String? location;

  @override
  bool get isRated => rating != null;

  Meal copyWith({
    String? title,
    String? photoPath,
    String? description,
    double? rating,
    String? review,
    DateTime? happenedOn,
    String? dish,
    double? price,
    String? company,
    String? location,
    bool clearPhoto = false,
    bool clearRating = false,
    bool clearPrice = false,
  }) {
    return Meal(
      id: id,
      title: title ?? this.title,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      description: description ?? this.description,
      rating: clearRating ? null : (rating ?? this.rating),
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      dish: dish ?? this.dish,
      price: clearPrice ? null : (price ?? this.price),
      company: company ?? this.company,
      location: location ?? this.location,
    );
  }
}

/// Input for creating a meal, before the store assigns an id.
class MealDraft {
  const MealDraft({
    required this.title,
    required this.happenedOn,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    this.dish,
    this.price,
    this.company,
    this.location,
  });

  final String title;
  final DateTime happenedOn;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final String? dish;
  final double? price;
  final String? company;
  final String? location;
}
