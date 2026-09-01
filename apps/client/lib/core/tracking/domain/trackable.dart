/// Lowest and highest score any tracked entry can be rated with.
const double kMinRating = 0.0;
const double kMaxRating = 10.0;

/// What every tracked entry has in common, whatever the domain.
///
/// The domains themselves have almost nothing in common — a room is escaped,
/// a meal has a dish, a gig has a venue — so this covers only the act of
/// tracking: what it was, when it happened, and what the owner thought of it.
/// Anything narrower than that belongs to the feature, not here.
abstract interface class Trackable {
  int get id;

  /// Display name of the entry: the room, the place, the band, the title.
  String get title;

  /// Absolute path to a cover image in the app documents directory.
  String? get photoPath;
  String? get description;

  /// Score from [kMinRating] to [kMaxRating], or null when not rated yet.
  double? get rating;
  String? get review;

  /// Calendar day the entry happened, normalised to midnight local time.
  DateTime get happenedOn;

  bool get isRated;
}
