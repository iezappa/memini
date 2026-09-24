import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/tracking/domain/tracked_domain.dart';
import '../domain/mood.dart';
import '../domain/recommendation.dart';

/// What people are playing, from RAWG.
///
/// The owner's own key, as with TMDB. RAWG requires its credit to appear as
/// an active hyperlink wherever its data is shown, which the shelf carries.
class RawgRecommendations implements RecommendationSource {
  const RawgRecommendations({required this.apiKey, this.client});

  final String? apiKey;
  final http.Client? client;

  static const _host = 'api.rawg.io';

  @override
  TrackedDomain get domain => TrackedDomain.games;

  @override
  String get attribution => 'RAWG';

  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  @override
  Future<List<Recommendation>> popular() async {
    if (!isConfigured) {
      throw const RecommendationException(RecommendationFailure.missingKey);
    }

    // Ordered by how many people added it lately rather than by score: a
    // list of the highest-rated games of all time never changes, and this
    // shelf is supposed to.
    return _ask({'ordering': '-added', 'page_size': '20'});
  }

  Future<List<Recommendation>> _ask(Map<String, String> query) async {
    final uri = Uri.https(_host, '/api/games', {
      'key': apiKey!.trim(),
      ...query,
    });

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

  @override
  Future<List<Recommendation>> forMood(Mood mood) async {
    if (!isConfigured) {
      throw const RecommendationException(RecommendationFailure.missingKey);
    }

    // A genre where RAWG has one for the mood, its nearest tag where it
    // does not — horror is a tag here, not a genre. Either way the answer
    // is narrowed to what somebody actually asked for rather than being
    // the week's most-added list wearing a label.
    return _ask({
      'ordering': '-added',
      'page_size': '20',
      // Only one of the two is ever set; the other is dropped.
      'genres': ?mood.rawgGenre,
      'tags': ?mood.rawgTag,
    });
  }

  /// Split out so the mapping can be tested without a network.
  static List<Recommendation> parse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const RecommendationException(RecommendationFailure.unavailable);
    }

    final results = decoded['results'];
    if (results is! List) return const [];

    final picks = <Recommendation>[];
    for (final raw in results) {
      if (raw is! Map<String, dynamic>) continue;

      final name = raw['name'] as String?;
      if (name == null || name.trim().isEmpty) continue;

      final released = raw['released'] as String?;
      final art = raw['background_image'];

      picks.add(
        Recommendation(
          domain: TrackedDomain.games,
          title: name,
          year: released != null && released.length >= 4
              ? int.tryParse(released.substring(0, 4))
              : null,
          imageUrl: art is String && art.trim().isNotEmpty ? art : null,
        ),
      );
    }

    return picks;
  }
}
