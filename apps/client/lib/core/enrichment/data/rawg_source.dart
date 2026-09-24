import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/enrichment.dart';

/// Games, from RAWG.
///
/// RAWG is free for personal use but requires the credit to appear as an
/// active hyperlink wherever its data is shown, so the attribution is part of
/// the contract rather than a nicety.
class RawgSource implements EnrichmentSource {
  const RawgSource({required this.apiKey, this.client});

  final String? apiKey;

  /// Injected by tests; production leaves it null and opens — and closes —
  /// its own client per lookup.
  final http.Client? client;

  static const _host = 'api.rawg.io';

  @override
  String get attribution => 'RAWG';

  @override
  String get attributionUrl => 'https://rawg.io/';

  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  @override
  Future<List<EnrichmentSuggestion>> search(String query) async {
    if (!isConfigured) {
      throw const EnrichmentException(EnrichmentFailure.missingKey);
    }

    final uri = Uri.https(_host, '/api/games', {
      'key': apiKey!.trim(),
      'search': query,
      'page_size': '10',
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
      throw const EnrichmentException(EnrichmentFailure.offline);
    } finally {
      if (client == null) connection.close();
    }
  }

  /// RAWG's search endpoint returns no description at all — the text about
  /// a game lives on its own page — so the paragraph costs one more request,
  /// made only for the game the owner actually picked.
  @override
  Future<EnrichmentSuggestion> details(EnrichmentSuggestion picked) async {
    if (!isConfigured) return picked;

    final uri = Uri.https(_host, '/api/games/${picked.externalId}', {
      'key': apiKey!.trim(),
    });

    final connection = client ?? http.Client();
    try {
      final response = await connection.get(uri);
      if (response.statusCode != 200) return picked;

      return picked.withDescription(parseAbout(response.body));
    } catch (_) {
      // The owner has already chosen. Losing the year, the platforms and
      // the cover over a paragraph that did not arrive would be the worse
      // trade, so a failure here is simply no description.
      return picked;
    } finally {
      if (client == null) connection.close();
    }
  }

  /// What RAWG's game page says about a game, in the shape a form can hold.
  ///
  /// Two parts, because the prose alone did not tell the owner anything:
  /// a line of facts — what kind of game it is, who made it, what it scored,
  /// how long it takes — and then the description itself. The facts are the
  /// half you can read at a glance; the prose is the half that says what
  /// playing it is like.
  static String? parseAbout(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;

    final facts = _facts(decoded);
    final prose = _prose(decoded['description_raw']);

    return switch ((facts, prose)) {
      (null, null) => null,
      (final String only, null) => only,
      (null, final String only) => only,
      (final String head, final String body) => '$head\n\n$body',
    };
  }

  /// The line above the description: genre, who made it, what it scored,
  /// how long it takes. Everything optional — RAWG knows all of it for a
  /// big release and almost none of it for a small one.
  static String? _facts(Map<String, dynamic> raw) {
    final developer = _namesOf(raw['developers'], limit: 2);
    final publisher = _namesOf(raw['publishers'], limit: 1);

    final parts = <String>[
      ?_namesOf(raw['genres'], limit: 3),
      ?developer,
      // Only when it is somebody else: on plenty of games the studio
      // publishes itself, and printing the same name twice says nothing.
      if (publisher != null && publisher != developer) publisher,
      ?_metacritic(raw['metacritic']),
      ?_playtime(raw['playtime']),
    ];

    return parts.isEmpty ? null : parts.join(' · ');
  }

  static String? _namesOf(Object? list, {required int limit}) {
    if (list is! List) return null;

    final names = <String>[];
    for (final entry in list) {
      if (entry is! Map<String, dynamic>) continue;
      final name = entry['name'];
      if (name is String && name.trim().isNotEmpty) names.add(name.trim());
      if (names.length == limit) break;
    }

    return names.isEmpty ? null : names.join(', ');
  }

  static String? _metacritic(Object? score) =>
      score is int ? 'Metacritic $score' : null;

  /// RAWG's `playtime` is the hours an average player put in. Rounded and
  /// marked as approximate, because that is what it is.
  static String? _playtime(Object? hours) =>
      hours is int && hours > 0 ? '~$hours h' : null;

  /// The description, kept to what fits in a form.
  ///
  /// RAWG's `description_raw` often repeats itself in three languages, one
  /// block after another, so anything past a blank line followed by a
  /// language name is dropped. What is left is capped at a sentence.
  static String? _prose(Object? raw) {
    if (raw is! String) return null;

    final paragraphs = <String>[];
    for (final part in raw.split(RegExp(r'\n\s*\n'))) {
      final paragraph = part.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (paragraph.isEmpty) continue;
      if (_isAnotherLanguage(paragraph)) break;
      paragraphs.add(paragraph);
      if (paragraphs.join(' ').length >= _proseLimit) break;
    }
    if (paragraphs.isEmpty) return null;

    return _shortened(paragraphs.join('\n\n'));
  }

  static const _proseLimit = 900;

  /// RAWG marks a translated block by naming the language on its own line,
  /// which is the only thing separating the English text from the rest.
  static bool _isAnotherLanguage(String paragraph) => RegExp(
    r'^(español|português|portugues|deutsch|français|francais|italiano|'
    r'русский|polski|中文|日本語|한국어)\b',
    caseSensitive: false,
  ).hasMatch(paragraph);

  /// Caps the text at a sentence rather than mid-word.
  static String _shortened(String text, {int limit = _proseLimit}) {
    if (text.length <= limit) return text;

    final cut = text.substring(0, limit);
    final stop = cut.lastIndexOf(RegExp(r'[.!?] '));

    return stop > limit ~/ 3
        ? cut.substring(0, stop + 1)
        : '${cut.trimRight()}…';
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

      final name = raw['name'] as String?;
      final id = raw['id'];
      if (name == null || name.trim().isEmpty || id is! int) continue;

      final platforms = <String>[];
      final rawPlatforms = raw['platforms'];
      if (rawPlatforms is List) {
        for (final entry in rawPlatforms) {
          if (entry is! Map<String, dynamic>) continue;
          final platform = entry['platform'];
          if (platform is Map<String, dynamic> && platform['name'] is String) {
            platforms.add(platform['name'] as String);
          }
        }
      }

      // RAWG hands back a whole URL rather than a path, and one picture
      // rather than two: the same wide still serves as the cover on a card
      // and as the backdrop behind a page.
      final art = raw['background_image'];
      final image = art is String && art.trim().isNotEmpty ? art : null;

      suggestions.add(
        EnrichmentSuggestion(
          externalId: '$id',
          title: name,
          releaseYear: _yearOf(raw['released'] as String?),
          platforms: platforms.isEmpty ? null : platforms.join(', '),
          posterUrl: image,
          backdropUrl: image,
        ),
      );
    }

    return suggestions;
  }

  static int? _yearOf(String? date) {
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }
}
