import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/enrichment/data/tmdb_source.dart';
import '../../../core/tracking/domain/tracked_domain.dart';
import '../domain/mood.dart';
import '../domain/recommendation.dart';

/// What is being watched this week, from TMDB.
///
/// The owner's own key, the same one the lookup uses: TMDB is free for
/// non-commercial use but the key belongs to the person, never to the build.
/// With no key there is nothing to ask, and the hub says so rather than
/// showing an empty shelf.
class TmdbRecommendations implements RecommendationSource {
  const TmdbRecommendations({required this.apiKey, this.client});

  final String? apiKey;

  /// Injected by tests; production opens — and closes — its own per call.
  final http.Client? client;

  static const _host = 'api.themoviedb.org';

  @override
  TrackedDomain get domain => TrackedDomain.screen;

  @override
  String get attribution => 'TMDB';

  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  @override
  Future<List<Recommendation>> popular() async {
    if (!isConfigured) {
      throw const RecommendationException(RecommendationFailure.missingKey);
    }

    // Trending rather than top-rated: a list of the best films ever made is
    // the same list every week, and the point of this shelf is that it
    // changes. `all` mixes films and series, which is what this section is.
    final uri = Uri.https(_host, '/3/trending/all/week', {
      'api_key': apiKey!.trim(),
    });

    return _ask(uri);
  }

  @override
  Future<List<Recommendation>> forMood(Mood mood) async {
    if (!isConfigured) {
      throw const RecommendationException(RecommendationFailure.missingKey);
    }

    // `vote_count.gte` is what keeps this useful. Sorted by popularity
    // alone a genre page fills with titles nobody has seen and nobody has
    // scored; a hundred votes is a low bar that still means somebody
    // watched it.
    return _ask(
      Uri.https(_host, '/3/discover/movie', {
        'api_key': apiKey!.trim(),
        'with_genres': mood.tmdbGenreId,
        'sort_by': 'popularity.desc',
        'vote_count.gte': '100',
        'include_adult': 'false',
      }),
    );
  }

  Future<List<Recommendation>> _ask(Uri uri) async {
    final connection = client ?? http.Client();
    try {
      final response = await connection.get(uri);
      if (response.statusCode != 200) {
        throw const RecommendationException(RecommendationFailure.unavailable);
      }
      return parse(response.body);
    } on RecommendationException {
      rethrow;
    } catch (_) {
      throw const RecommendationException(RecommendationFailure.unavailable);
    } finally {
      if (client == null) connection.close();
    }
  }

  /// Split out so the mapping can be tested without a network.
  static List<Recommendation> parse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const RecommendationException(RecommendationFailure.unavailable);
    }

    final results = decoded['results'];
    if (results is! List) return const [];

    return [
      for (final raw in results)
        if (raw is Map<String, dynamic>) ?_oneOf(raw),
    ];
  }

  static Recommendation? _oneOf(Map<String, dynamic> raw) {
    // Trending also returns people, who have no title and cannot be watched.
    // `/discover/movie` returns films only and carries no `media_type` at
    // all, so an absent one is fine while a present one has to be a film
    // or a series.
    final mediaType = raw['media_type'];
    if (mediaType != null && mediaType != 'movie' && mediaType != 'tv') {
      return null;
    }

    final title = (raw['title'] ?? raw['name']) as String?;
    if (title == null || title.trim().isEmpty) return null;

    final overview = raw['overview'] as String?;
    final date = (raw['release_date'] ?? raw['first_air_date']) as String?;

    return Recommendation(
      domain: TrackedDomain.screen,
      title: title,
      year: date != null && date.length >= 4
          ? int.tryParse(date.substring(0, 4))
          : null,
      overview: (overview == null || overview.trim().isEmpty) ? null : overview,
      // The same host and size the lookup uses, so a suggestion and a saved
      // entry show the same picture.
      imageUrl: TmdbSource.imageUrl(raw['poster_path'], 'w500'),
    );
  }
}
