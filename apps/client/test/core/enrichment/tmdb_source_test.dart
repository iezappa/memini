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
    });

    test('builds the artwork URLs the search already handed it', () {
      // The bug this covers: the response carried `poster_path` all along —
      // this file's own fixture above has had one since it was written — and
      // the parser dropped it, so no entry ever had a cover.
      final results = TmdbSource.parseSearch('''
        {"results": [{
          "id": 335984,
          "media_type": "movie",
          "title": "Blade Runner 2049",
          "poster_path": "/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg",
          "backdrop_path": "/ilRyazdMLwzhbWR5tXVMUyCoJgP.jpg"
        }]}
      ''');

      expect(
        results.single.posterUrl,
        'https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
      );
      expect(
        results.single.backdropUrl,
        'https://image.tmdb.org/t/p/w1280/ilRyazdMLwzhbWR5tXVMUyCoJgP.jpg',
      );
    });

    test('leaves the artwork null for a title that has none', () {
      // TMDB reports a missing image as a null path, not as an absent key.
      final results = TmdbSource.parseSearch('''
        {"results": [{
          "id": 1,
          "media_type": "movie",
          "title": "Something obscure",
          "poster_path": null,
          "backdrop_path": ""
        }]}
      ''');

      expect(results.single.posterUrl, isNull);
      expect(results.single.backdropUrl, isNull);
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
