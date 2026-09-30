import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memini/core/enrichment/data/open_library_source.dart';
import 'package:memini/core/enrichment/domain/enrichment.dart';

void main() {
  group('OpenLibrarySource', () {
    test(
      'maps title author year cover and description from search results',
      () async {
        final source = OpenLibrarySource(
          client: MockClient((request) async {
            expect(request.url.host, 'openlibrary.org');
            expect(request.url.path, '/search.json');
            expect(request.url.queryParameters['title'], 'Kindred');
            expect(request.url.queryParameters['author'], 'Octavia Butler');
            return http.Response('''
            {
              "docs": [
                {
                  "key": "/works/OL123W",
                  "title": "Kindred",
                  "author_name": ["Octavia E. Butler", "Other"],
                  "first_publish_year": 1979,
                  "cover_i": 12345
                }
              ]
            }
          ''', 200);
          }),
        );

        final results = await source.search('Kindred Octavia Butler');

        expect(results, hasLength(1));
        expect(results.single.externalId, '/works/OL123W');
        expect(results.single.title, 'Kindred');
        expect(results.single.releaseYear, 1979);
        expect(results.single.author, 'Octavia E. Butler');
        expect(
          results.single.posterUrl,
          'https://covers.openlibrary.org/b/id/12345-L.jpg',
        );
      },
    );

    test(
      'ignores malformed documents and treats malformed payloads as failed',
      () async {
        final source = OpenLibrarySource(
          client: MockClient(
            (_) async => http.Response('{"docs":[{},42]}', 200),
          ),
        );

        expect(await source.search('bad'), isEmpty);

        final broken = OpenLibrarySource(
          client: MockClient((_) async => http.Response('not-json', 200)),
        );
        await expectLater(
          broken.search('bad'),
          throwsA(isA<EnrichmentException>()),
        );
      },
    );
  });
}
