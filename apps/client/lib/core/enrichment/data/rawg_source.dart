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

      suggestions.add(
        EnrichmentSuggestion(
          externalId: '$id',
          title: name,
          imageUrl: raw['background_image'] as String?,
          releaseYear: _yearOf(raw['released'] as String?),
          platforms: platforms.isEmpty ? null : platforms.join(', '),
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
