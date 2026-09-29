import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/enrichment.dart';

/// Books, from Open Library's keyless public search API.
class OpenLibrarySource implements EnrichmentSource {
  const OpenLibrarySource({this.client});

  /// Injected by tests; production opens and closes its own client per lookup.
  final http.Client? client;

  static const _host = 'openlibrary.org';
  static const _coverBase = 'https://covers.openlibrary.org/b/id';

  @override
  String get attribution => 'Open Library';

  @override
  String get attributionUrl => 'https://openlibrary.org/';

  @override
  bool get isConfigured => true;

  @override
  Future<List<EnrichmentSuggestion>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final parts = trimmed.split(RegExp(r'\s+'));
    final title = parts.first;
    final author = parts.length <= 1 ? null : parts.skip(1).join(' ');
    final params = {
      'title': title,
      if (author != null && author.isNotEmpty) 'author': author,
      'limit': '10',
    };
    final uri = Uri.https(_host, '/search.json', params);

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

  @override
  Future<EnrichmentSuggestion> details(EnrichmentSuggestion picked) async => picked;

  static List<EnrichmentSuggestion> parseSearch(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const EnrichmentException(EnrichmentFailure.failed);
    }

    final docs = decoded['docs'];
    if (docs is! List) return const [];

    final suggestions = <EnrichmentSuggestion>[];
    for (final raw in docs) {
      if (raw is! Map<String, dynamic>) continue;

      final title = raw['title'];
      final key = raw['key'];
      if (title is! String || title.trim().isEmpty || key is! String) continue;

      suggestions.add(
        EnrichmentSuggestion(
          externalId: key,
          title: title,
          releaseYear: raw['first_publish_year'] is int
              ? raw['first_publish_year'] as int
              : null,
          author: _authors(raw['author_name']),
          posterUrl: _coverUrl(raw['cover_i']),
        ),
      );
    }
    return suggestions;
  }

  static String? _authors(Object? value) {
    if (value is! List) return null;
    final names = [
      for (final item in value)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
    if (names.isEmpty) return null;
    return names.first;
  }

  static String? _coverUrl(Object? coverId) => coverId is int
      ? '$_coverBase/$coverId-L.jpg'
      : null;
}
