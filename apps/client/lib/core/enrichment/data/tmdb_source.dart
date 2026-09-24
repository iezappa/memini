import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/enrichment.dart';

/// Films and series, from The Movie Database.
///
/// TMDB is free for non-commercial use but requires the credit to stay
/// visible and forbids use in machine-learning applications, so the key is
/// the owner's own — never one shipped with the app.
class TmdbSource implements EnrichmentSource {
  const TmdbSource({required this.apiKey, this.client});

  final String? apiKey;

  /// Injected by tests; production leaves it null and opens — and closes —
  /// its own client per lookup.
  final http.Client? client;

  static const _host = 'api.themoviedb.org';

  /// Where the artwork is served from, and at what size.
  ///
  /// TMDB returns a path and expects the caller to build the URL, which is
  /// how the poster went missing: the search response had it all along —
  /// the fixture in this repo's own test carries a `poster_path` — and the
  /// parser simply never read it.
  ///
  /// `w500` for the cover and `w1280` for the still: enough for a phone at
  /// three times the density and for a blurred backdrop behind a page,
  /// without pulling the original down a mobile connection.
  static const _images = 'https://image.tmdb.org/t/p';
  static const _posterSize = 'w500';
  static const _backdropSize = 'w1280';

  /// Null for a title with no artwork, which TMDB reports as a null path.
  static String? imageUrl(Object? path, String size) {
    if (path is! String || path.trim().isEmpty) return null;
    return '$_images/$size$path';
  }

  @override
  String get attribution => 'TMDB';

  @override
  String get attributionUrl => 'https://www.themoviedb.org/';

  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  @override
  Future<List<EnrichmentSuggestion>> search(String query) async {
    if (!isConfigured) {
      throw const EnrichmentException(EnrichmentFailure.missingKey);
    }

    final uri = Uri.https(_host, '/3/search/multi', {
      'api_key': apiKey!.trim(),
      'query': query,
      'include_adult': 'false',
    });

    final connection = client ?? http.Client();
    try {
      final response = await connection.get(uri);
      if (response.statusCode != 200) {
        throw const EnrichmentException(EnrichmentFailure.failed);
      }
      return parseSearch(response.body);
    } on EnrichmentException {
      rethrow;
    } on FormatException {
      throw const EnrichmentException(EnrichmentFailure.failed);
    } catch (_) {
      // Socket and handshake failures all mean the same thing to the owner.
      throw const EnrichmentException(EnrichmentFailure.offline);
    } finally {
      if (client == null) connection.close();
    }
  }

  /// Split out from [search] so the mapping can be tested without a network.
  static List<EnrichmentSuggestion> parseSearch(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const EnrichmentException(EnrichmentFailure.failed);
    }

    final results = decoded['results'];
    if (results is! List) return const [];

    final suggestions = <EnrichmentSuggestion>[];
    for (final raw in results) {
      if (raw is! Map<String, dynamic>) continue;

      // /search/multi also returns people, which have no title at all.
      final mediaType = raw['media_type'];
      if (mediaType != 'movie' && mediaType != 'tv') continue;

      // Films carry "title", series carry "name".
      final title = (raw['title'] ?? raw['name']) as String?;
      final id = raw['id'];
      if (title == null || title.trim().isEmpty || id is! int) continue;

      final date = (raw['release_date'] ?? raw['first_air_date']) as String?;
      final overview = raw['overview'] as String?;

      suggestions.add(
        EnrichmentSuggestion(
          externalId: '$id',
          title: title,
          description: (overview == null || overview.trim().isEmpty)
              ? null
              : overview,
          releaseYear: _yearOf(date),
          posterUrl: imageUrl(raw['poster_path'], _posterSize),
          backdropUrl: imageUrl(raw['backdrop_path'], _backdropSize),
        ),
      );
    }

    return suggestions;
  }

  /// TMDB returns an empty string, not null, for an unknown date.
  static int? _yearOf(String? date) {
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }
}
