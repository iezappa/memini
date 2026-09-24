import '../../../core/tracking/domain/tracked_domain.dart';
import 'mood.dart';

/// Something to watch or play, suggested rather than logged.
///
/// Deliberately thin: a picture, a title, a year and where it came from.
/// It is a nudge, not a record — nothing about it is stored, and opening
/// the app tomorrow brings a different one.
class Recommendation {
  const Recommendation({
    required this.domain,
    required this.title,
    this.year,
    this.overview,
    this.imageUrl,
  });

  final TrackedDomain domain;
  final String title;
  final int? year;
  final String? overview;
  final String? imageUrl;
}

/// What the hub could not show, and why.
enum RecommendationFailure {
  /// No key is set for the source this domain needs.
  missingKey,

  /// The request could not be made or came back wrong.
  unavailable,
}

class RecommendationException implements Exception {
  const RecommendationException(this.failure);

  final RecommendationFailure failure;

  @override
  String toString() => 'RecommendationException($failure)';
}

/// Where the hub's suggestions come from.
abstract interface class RecommendationSource {
  /// Which section a suggestion from here belongs to.
  TrackedDomain get domain;

  /// Whether a request can even be attempted — false when a key is missing.
  bool get isConfigured;

  /// The name shown in the attribution line, which both TMDB and RAWG
  /// require to be visible wherever their data is.
  String get attribution;

  /// A page of what is popular now, in no particular order.
  ///
  /// A page rather than one pick: the caller chooses at random from it, so
  /// a second look costs nothing and the same title does not come back
  /// every time the hub is opened.
  Future<List<Recommendation>> popular();

  /// A page of whatever answers [mood], or null where this source cannot
  /// be asked that.
  ///
  /// Null rather than falling back to [popular]: "I feel like laughing"
  /// answered with whatever is trending is worse than not answering, since
  /// the owner cannot tell the two apart.
  Future<List<Recommendation>>? forMood(Mood mood);
}
