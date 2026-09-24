import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memini/core/enrichment/data/rawg_source.dart';
import 'package:memini/core/enrichment/domain/enrichment.dart';

void main() {
  group('RawgSource.parseSearch', () {
    test('maps a game with its year and platforms', () {
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

  group('RawgSource.details', () {
    late List<Uri> requests;

    /// A client that answers the game page with [body] and records what was
    /// asked for.
    http.Client answering(String body, {int status = 200}) {
      return MockClient((request) async {
        requests.add(request.url);
        return http.Response(body, status, headers: const {
          'content-type': 'application/json; charset=utf-8',
        });
      });
    }

    const picked = EnrichmentSuggestion(
      externalId: '22511',
      title: 'Outer Wilds',
      releaseYear: 2019,
      platforms: 'PC',
      posterUrl: 'https://media.rawg.io/outer-wilds.jpg',
    );

    setUp(() => requests = []);

    test('asks the game its own page for the description', () async {
      final source = RawgSource(
        apiKey: 'k',
        client: answering(
          jsonEncode({'description_raw': 'You are the newest recruit.'}),
        ),
      );

      final detailed = await source.details(picked);

      expect(requests.single.path, '/api/games/22511');
      expect(detailed.description, 'You are the newest recruit.');
      // Everything the search found is still on it.
      expect(detailed.title, 'Outer Wilds');
      expect(detailed.releaseYear, 2019);
      expect(detailed.posterUrl, 'https://media.rawg.io/outer-wilds.jpg');
    });

    test('keeps the first paragraph and leaves the rest on RAWG', () async {
      final source = RawgSource(
        apiKey: 'k',
        client: answering(
          jsonEncode({
            'description_raw':
                'You are the newest recruit.\n\nEspañol: Eres el recluta.',
          }),
        ),
      );

      final detailed = await source.details(picked);

      expect(detailed.description, 'You are the newest recruit.');
    });

    test('a paragraph too long for a form is cut at a sentence', () async {
      final sentence = '${'Wide open space. ' * 60}And then the sun.';
      final source = RawgSource(
        apiKey: 'k',
        client: answering(jsonEncode({'description_raw': sentence})),
      );

      final detailed = await source.details(picked);

      expect(detailed.description!.length, lessThanOrEqualTo(600));
      expect(detailed.description, endsWith('.'));
      expect(detailed.description, isNot(contains('And then the sun')));
    });

    test('a game with no text keeps its description null', () async {
      final source = RawgSource(
        apiKey: 'k',
        client: answering(jsonEncode({'description_raw': '   '})),
      );

      expect((await source.details(picked)).description, isNull);
    });

    test('a page that will not load costs the description, not the pick', () async {
      final source = RawgSource(
        apiKey: 'k',
        client: answering('nope', status: 500),
      );

      final detailed = await source.details(picked);

      expect(detailed.description, isNull);
      expect(detailed.title, 'Outer Wilds');
      expect(detailed.platforms, 'PC');
    });

    test('a request that throws hands back what was picked', () async {
      final source = RawgSource(
        apiKey: 'k',
        client: MockClient((_) => throw const SocketExceptionStub()),
      );

      expect((await source.details(picked)).title, 'Outer Wilds');
    });

    test('with no key there is nothing to ask', () async {
      const source = RawgSource(apiKey: '');

      expect(await source.details(picked), same(picked));
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

/// Stands in for a connection that never opened.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
