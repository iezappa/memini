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

  /// Everything MusicBrainz knows about an artist is already in the search
  /// answer, so there is nothing further to ask for.
  @override
  Future<EnrichmentSuggestion> details(EnrichmentSuggestion picked) async =>
      picked;

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

      final area = raw['area'];
      final areaName = area is Map<String, dynamic>
          ? area['name'] as String?
          : null;

      suggestions.add(
        EnrichmentSuggestion(
          externalId: id,
          title: name,
          description: about(raw),
          // MusicBrainz itself carries no images, and the Cover Art Archive
          // keys art by release rather than artist — a band has no one cover.
          releaseYear: _yearOf(raw['life-span']),
          origin: areaName,
        ),
      );
    }

    return suggestions;
  }

  /// What is known about an act, in one line.
  ///
  /// MusicBrainz is a database of facts, not an encyclopaedia: there is no
  /// biography to fetch, from this endpoint or any other. So the "about" is
  /// assembled from the facts it does hold — what kind of act it is, where
  /// it is from, the years it was active, what people tag it as — which is
  /// the same line a person would write if asked to describe a band in one
  /// breath.
  ///
  /// Separators rather than sentences, and the source's own words wherever
  /// there are any, because this text lands in a form the owner reads in
  /// whichever language they use the app in. It is a starting point they can
  /// rewrite, not a paragraph pretending to be prose.
  static String? about(Map<String, dynamic> raw) {
    final parts = <String>[
      // The disambiguation is a human-written phrase — "US alternative rock
      // band" — and beats anything assembled from fields, so it leads.
      ?_text(raw['disambiguation']) ?? _text(raw['type']),
      ?_placeOf(raw),
      ?_yearsOf(raw['life-span']),
      ?_tagsOf(raw['tags']),
    ];

    return parts.isEmpty ? null : parts.join(' · ');
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _nameOf(Object? value) =>
      value is Map<String, dynamic> ? _text(value['name']) : null;

  /// The town it started in and the country, when both are known and are not
  /// the same word twice.
  static String? _placeOf(Map<String, dynamic> raw) {
    final town = _nameOf(raw['begin-area']);
    final country = _nameOf(raw['area']);
    if (town == null) return country;
    if (country == null || country == town) return town;

    return '$town, $country';
  }

  /// `1994–2010`, or `1994–` while it is still going.
  static String? _yearsOf(Object? lifeSpan) {
    if (lifeSpan is! Map<String, dynamic>) return null;

    final begin = _year(lifeSpan['begin']);
    final end = _year(lifeSpan['end']);
    if (begin == null) return end == null ? null : '–$end';

    return '$begin–${end ?? ''}';
  }

  static String? _year(Object? date) =>
      date is String && date.length >= 4 ? date.substring(0, 4) : null;

  /// What listeners tag the act as, which is the nearest thing MusicBrainz
  /// has to a genre. The three most tagged, because a well-known band
  /// carries thirty and the field is one line.
  static String? _tagsOf(Object? tags) {
    if (tags is! List) return null;

    final counted = <(int, String)>[];
    for (final tag in tags) {
      if (tag is! Map<String, dynamic>) continue;
      final name = _text(tag['name']);
      if (name == null) continue;
      counted.add((tag['count'] is int ? tag['count'] as int : 0, name));
    }
    if (counted.isEmpty) return null;

    counted.sort((a, b) => b.$1.compareTo(a.$1));

    return counted.take(3).map((tag) => tag.$2).join(', ');
  }

  /// The year the artist began, which reads as their "release year" here.
  static int? _yearOf(Object? lifeSpan) {
    if (lifeSpan is! Map<String, dynamic>) return null;
    final begin = lifeSpan['begin'];
    if (begin is! String || begin.length < 4) return null;
    return int.tryParse(begin.substring(0, 4));
  }
}
