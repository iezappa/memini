import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/enrichment/data/rawg_source.dart';
import 'package:memini/core/enrichment/domain/enrichment.dart';

void main() {
  group('RawgSource.parseSearch', () {
    test('maps a game with its cover, year and platforms', () {
      final results = RawgSource.parseSearch('''
        {"results": [{
          "id": 22511,
          "name": "Outer Wilds",
          "released": "2019-05-28",
          "background_image": "https://media.rawg.io/outer-wilds.jpg",
          "platforms": [
            {"platform": {"id": 4, "name": "PC"}},
            {"platform": {"id": 7, "name": "Nintendo Switch"}}
          ]
        }]}
      ''');

      expect(results, hasLength(1));
      expect(results.single.externalId, '22511');
      expect(results.single.title, 'Outer Wilds');
      expect(results.single.releaseYear, 2019);
      expect(results.single.imageUrl, 'https://media.rawg.io/outer-wilds.jpg');
      expect(results.single.platforms, 'PC, Nintendo Switch');
    });

    test('a game with no platforms leaves the field null, not empty', () {
      final results = RawgSource.parseSearch('''
        {"results": [{"id": 1, "name": "Unknown", "platforms": []}]}
      ''');

      expect(results.single.platforms, isNull);
    });

    test('skips a malformed row instead of failing the whole search', () {
      final results = RawgSource.parseSearch('''
        {"results": [
          {"id": 1},
          {"name": "No id"},
          {"id": 2, "name": "Hades"}
        ]}
      ''');

      expect(results.map((r) => r.title), ['Hades']);
    });

    test('an unreleased game has no year', () {
      final results = RawgSource.parseSearch('''
        {"results": [{"id": 1, "name": "Someday", "released": null}]}
      ''');

      expect(results.single.releaseYear, isNull);
    });

    test('no results is an empty list, not a failure', () {
      expect(RawgSource.parseSearch('{"results": []}'), isEmpty);
    });
  });

  test('searching without a key reports the missing key', () {
    expect(
      () => const RawgSource(apiKey: '').search('hades'),
      throwsA(
        isA<EnrichmentException>().having(
          (e) => e.reason,
          'reason',
          EnrichmentFailure.missingKey,
        ),
      ),
    );
  });
}
