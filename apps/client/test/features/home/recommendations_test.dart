import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/tracking/domain/tracked_domain.dart';
import 'package:memini/features/home/data/rawg_recommendations.dart';
import 'package:memini/features/home/data/tmdb_recommendations.dart';
import 'package:memini/features/home/domain/recommendation.dart';

void main() {
  group('TmdbRecommendations', () {
    test('maps a film and a series, artwork and all', () {
      final picks = TmdbRecommendations.parse('''
        {"results": [
          {
            "media_type": "movie",
            "title": "Blade Runner 2049",
            "release_date": "2017-10-04",
            "overview": "A blade runner unearths a secret.",
            "poster_path": "/poster.jpg"
          },
          {
            "media_type": "tv",
            "name": "Severance",
            "first_air_date": "2022-02-18",
            "poster_path": "/severance.jpg"
          }
        ]}
      ''');

      expect(picks, hasLength(2));
      expect(picks.first.title, 'Blade Runner 2049');
      expect(picks.first.year, 2017);
      expect(picks.first.overview, 'A blade runner unearths a secret.');
      expect(
        picks.first.imageUrl,
        'https://image.tmdb.org/t/p/w500/poster.jpg',
      );
      expect(picks.last.title, 'Severance', reason: 'a series carries "name"');
      expect(picks.every((pick) => pick.domain == TrackedDomain.screen), true);
    });

    test('drops the people trending returns', () {
      // `/trending/all` mixes in actors, who have no title and cannot be
      // watched.
      final picks = TmdbRecommendations.parse('''
        {"results": [
          {"media_type": "person", "name": "Denis Villeneuve"},
          {"media_type": "movie", "title": "Dune"}
        ]}
      ''');

      expect(picks.map((pick) => pick.title), ['Dune']);
    });

    test('refuses to ask without a key, rather than asking badly', () {
      const source = TmdbRecommendations(apiKey: '  ');

      expect(source.isConfigured, isFalse);
      expect(
        source.popular,
        throwsA(
          isA<RecommendationException>().having(
            (error) => error.failure,
            'failure',
            RecommendationFailure.missingKey,
          ),
        ),
      );
    });

    test('reads a body that is not what it expected as unavailable', () {
      expect(
        () => TmdbRecommendations.parse('["not", "an", "object"]'),
        throwsA(isA<RecommendationException>()),
      );
    });
  });

  group('RawgRecommendations', () {
    test('maps a game, with the one still RAWG gives', () {
      final picks = RawgRecommendations.parse('''
        {"results": [{
          "name": "Outer Wilds",
          "released": "2019-05-28",
          "background_image": "https://media.rawg.io/outer-wilds.jpg"
        }]}
      ''');

      expect(picks.single.title, 'Outer Wilds');
      expect(picks.single.year, 2019);
      expect(picks.single.imageUrl, 'https://media.rawg.io/outer-wilds.jpg');
      expect(picks.single.domain, TrackedDomain.games);
    });

    test('leaves the picture null when there is none', () {
      final picks = RawgRecommendations.parse('''
        {"results": [{"name": "Something obscure", "background_image": null}]}
      ''');

      expect(picks.single.imageUrl, isNull);
    });

    test('skips a row with no name', () {
      final picks = RawgRecommendations.parse('''
        {"results": [{"released": "2019-05-28"}, {"name": "Hades"}]}
      ''');

      expect(picks.map((pick) => pick.title), ['Hades']);
    });

    test('refuses to ask without a key', () {
      const source = RawgRecommendations(apiKey: null);

      expect(source.isConfigured, isFalse);
      expect(source.popular, throwsA(isA<RecommendationException>()));
    });
  });
}
