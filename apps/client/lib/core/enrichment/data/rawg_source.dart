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

  /// The first paragraph of a game's description, or null.
  ///
  /// RAWG's `description_raw` runs to several paragraphs and often repeats
  /// itself in three languages, one after another. The owner asked for a
  /// short "about", and the first paragraph is the one that reads like one;
  /// the rest belongs on RAWG's own page.
  static String? parseAbout(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;

    final raw = decoded['description_raw'];
    if (raw is! String) return null;

    final paragraph = raw
        .split(RegExp(r'\n\s*\n'))
        .map((part) => part.trim())
        .firstWhere((part) => part.isNotEmpty, orElse: () => '');
    if (paragraph.isEmpty) return null;

    return _shortened(paragraph.replaceAll(RegExp(r'\s+'), ' '));
  }

  /// Caps a paragraph at a sentence rather than mid-word.
  ///
  /// A few games answer with a wall of text in one paragraph, and the point
  /// of this field is a description the owner can read at a glance and then
  /// edit — it lands in a form, not in an article.
  static String _shortened(String text, {int limit = 600}) {
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
