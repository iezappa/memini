import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/enrichment/data/tmdb_source.dart';
import 'package:memini/core/enrichment/domain/enrichment.dart';

void main() {
  group('TmdbSource.parseSearch', () {
    test('maps a film, taking the title and the release year', () {
      final results = TmdbSource.parseSearch('''
        {"results": [{
          "id": 335984,
          "media_type": "movie",
          "title": "Blade Runner 2049",
          "overview": "A blade runner unearths a secret.",
          "poster_path": "/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg",
          "release_date": "2017-10-04"
        }]}
      ''');

      expect(results, hasLength(1));
      expect(results.single.externalId, '335984');
      expect(results.single.title, 'Blade Runner 2049');
      expect(results.single.description, 'A blade runner unearths a secret.');
      expect(results.single.releaseYear, 2017);
      expect(
        results.single.imageUrl,
        '${TmdbSource.posterBase}/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
      );
    });

    test('a series carries "name" and "first_air_date", not "title"', () {
      final results = TmdbSource.parseSearch('''
        {"results": [{
          "id": 95396,
          "media_type": "tv",
          "name": "Severance",
          "first_air_date": "2022-02-17"
        }]}
      ''');

      expect(results.single.title, 'Severance');
      expect(results.single.releaseYear, 2022);
    });

    test('drops people, which a multi search also returns', () {
      final results = TmdbSource.parseSearch('''
        {"results": [
          {"id": 1, "media_type": "person", "name": "Denis Villeneuve"},
          {"id": 2, "media_type": "movie", "title": "Dune"}
        ]}
      ''');

      expect(results.map((r) => r.title), ['Dune']);
    });

    test('an empty release date does not become year zero', () {
      final results = TmdbSource.parseSearch('''
        {"results": [{
          "id": 1, "media_type": "movie", "title": "Unreleased",
          "release_date": ""
        }]}
      ''');

      expect(results.single.releaseYear, isNull);
    });

    test('a missing poster leaves the image null, not a broken URL', () {
      final results = TmdbSource.parseSearch('''
        {"results": [{
          "id": 1, "media_type": "movie", "title": "No poster",
          "poster_path": null
        }]}
      ''');

      expect(results.single.imageUrl, isNull);
    });

    test('an empty overview stays null rather than blanking a description', () {
      final results = TmdbSource.parseSearch('''
        {"results": [{
          "id": 1, "media_type": "movie", "title": "Bare", "overview": ""
        }]}
      ''');

      expect(results.single.description, isNull);
    });

    test('no results is an empty list, not a failure', () {
      expect(TmdbSource.parseSearch('{"results": []}'), isEmpty);
    });

    test('a payload that is not an object is a failure', () {
      expect(
        () => TmdbSource.parseSearch('[]'),
        throwsA(
          isA<EnrichmentException>().having(
            (e) => e.reason,
            'reason',
            EnrichmentFailure.failed,
          ),
        ),
      );
    });
  });

  group('TmdbSource.isConfigured', () {
    test('is false without a key, and false for a blank one', () {
      expect(const TmdbSource(apiKey: null).isConfigured, isFalse);
      expect(const TmdbSource(apiKey: '   ').isConfigured, isFalse);
      expect(const TmdbSource(apiKey: 'abc').isConfigured, isTrue);
    });

    test('searching without a key reports the missing key, not a failure', () {
      expect(
        () => const TmdbSource(apiKey: null).search('dune'),
        throwsA(
          isA<EnrichmentException>().having(
            (e) => e.reason,
            'reason',
            EnrichmentFailure.missingKey,
          ),
        ),
      );
    });
  });
}
