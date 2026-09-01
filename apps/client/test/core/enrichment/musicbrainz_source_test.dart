import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/enrichment/data/musicbrainz_source.dart';

void main() {
  group('MusicBrainzSource.parseSearch', () {
    test('maps an artist with its disambiguation and origin', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{
          "id": "a74b1b7f-71a5-4011-9441-d0b5e4122711",
          "name": "Radiohead",
          "disambiguation": "UK alternative rock band",
          "area": {"name": "United Kingdom"},
          "life-span": {"begin": "1991"}
        }]}
      ''');

      expect(results, hasLength(1));
      expect(results.single.externalId, 'a74b1b7f-71a5-4011-9441-d0b5e4122711');
      expect(results.single.title, 'Radiohead');
      expect(results.single.description, 'UK alternative rock band');
      expect(results.single.origin, 'United Kingdom');
      expect(results.single.releaseYear, 1991);
    });

    test(
      'carries no cover art, because art is keyed by release not artist',
      () {
        final results = MusicBrainzSource.parseSearch('''
        {"artists": [{"id": "x", "name": "Spinetta"}]}
      ''');

        expect(results.single.imageUrl, isNull);
      },
    );

    test('a full begin date still yields just the year', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{
          "id": "x", "name": "Soda Stereo",
          "life-span": {"begin": "1982-08-01"}
        }]}
      ''');

      expect(results.single.releaseYear, 1982);
    });

    test('skips an entry with no name', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{"id": "x"}, {"id": "y", "name": "Real"}]}
      ''');

      expect(results.map((r) => r.title), ['Real']);
    });

    test('needs no key at all', () {
      expect(
        const MusicBrainzSource(userAgent: 'Memini/1.0').isConfigured,
        isTrue,
      );
    });

    test('the subtitle strings the known facts together', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{
          "id": "x", "name": "Radiohead",
          "area": {"name": "United Kingdom"},
          "life-span": {"begin": "1991"}
        }]}
      ''');

      expect(results.single.subtitle, '1991 · United Kingdom');
    });
  });
}
