import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/enrichment.dart';

/// Artists, from MusicBrainz, with covers from the Cover Art Archive.
///
/// No key is needed, but MusicBrainz requires a User-Agent that identifies
/// the application and throttles anonymous callers hard, so the header is not
/// optional. It also asks for at most one request per second.
class MusicBrainzSource implements EnrichmentSource {
  const MusicBrainzSource({required this.userAgent, this.client});

  /// Identifies this app to MusicBrainz, per their rate-limiting rules.
  final String userAgent;

  /// Injected by tests; production leaves it null and opens — and closes —
  /// its own client per lookup.
  final http.Client? client;

  static const _host = 'musicbrainz.org';

  @override
  String get attribution => 'MusicBrainz';

  @override
  String get attributionUrl => 'https://musicbrainz.org/';

  /// Always available: this source needs no key at all.
  @override
  bool get isConfigured => true;

  @override
  Future<List<EnrichmentSuggestion>> search(String query) async {
    final uri = Uri.https(_host, '/ws/2/artist', {
      'query': query,
      'fmt': 'json',
      'limit': '10',
    });

    final connection = client ?? http.Client();
    try {
      final response = await connection.get(
        uri,
        headers: {'User-Agent': userAgent},
      );
      if (response.statusCode != 200) {
        throw const EnrichmentException(EnrichmentFailure.failed);
      }
      return parseSearch(response.body);
    } on EnrichmentException {
      rethrow;
    } on FormatException {
      throw const EnrichmentException(EnrichmentFailure.failed);
    } catch (_) {
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

    final artists = decoded['artists'];
    if (artists is! List) return const [];

    final suggestions = <EnrichmentSuggestion>[];
    for (final raw in artists) {
      if (raw is! Map<String, dynamic>) continue;

      final name = raw['name'] as String?;
      final id = raw['id'] as String?;
      if (name == null || name.trim().isEmpty || id == null) continue;

      // The disambiguation is what tells two bands with the same name apart,
      // which is the whole reason to look an artist up rather than type it.
      final disambiguation = raw['disambiguation'] as String?;
      final area = raw['area'];
      final areaName = area is Map<String, dynamic>
          ? area['name'] as String?
          : null;

      suggestions.add(
        EnrichmentSuggestion(
          externalId: id,
          title: name,
          description: (disambiguation == null || disambiguation.isEmpty)
              ? null
              : disambiguation,
          // MusicBrainz itself carries no images, and the Cover Art Archive
          // keys art by release rather than artist — a band has no one cover.
          releaseYear: _yearOf(raw['life-span']),
          origin: areaName,
        ),
      );
    }

    return suggestions;
  }

  /// The year the artist began, which reads as their "release year" here.
  static int? _yearOf(Object? lifeSpan) {
    if (lifeSpan is! Map<String, dynamic>) return null;
    final begin = lifeSpan['begin'];
    if (begin is! String || begin.length < 4) return null;
    return int.tryParse(begin.substring(0, 4));
  }
}
