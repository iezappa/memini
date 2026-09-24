import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/enrichment/data/musicbrainz_source.dart';

void main() {
  group('MusicBrainzSource.parseSearch', () {
    test('maps an artist with its origin and the years it was active', () {
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
      expect(
        results.single.description,
        'UK alternative rock band · United Kingdom · 1991–',
      );
      expect(results.single.origin, 'United Kingdom');
      expect(results.single.releaseYear, 1991);
    });

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

    test('the about leads with the phrase a person wrote', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{
          "id": "x", "name": "Wilco", "type": "Group",
          "disambiguation": "US alternative rock band",
          "area": {"name": "United States"},
          "begin-area": {"name": "Chicago"},
          "life-span": {"begin": "1994"},
          "tags": [
            {"count": 2, "name": "indie"},
            {"count": 9, "name": "alternative rock"},
            {"count": 5, "name": "americana"},
            {"count": 1, "name": "rock"}
          ]
        }]}
      ''');

      // The town and the country, the years, and the three tags most people
      // agreed on — in that order, most-tagged first.
      expect(
        results.single.description,
        'US alternative rock band · Chicago, United States · 1994– · '
        'alternative rock, americana, indie',
      );
    });

    test('falls back to what kind of act it is when nobody wrote a phrase', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{"id": "x", "name": "Nobody", "type": "Person"}]}
      ''');

      expect(results.single.description, 'Person');
    });

    test('an act that has ended carries both years', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{
          "id": "x", "name": "Talking Heads",
          "life-span": {"begin": "1975-01-01", "end": "1991-12-01"}
        }]}
      ''');

      expect(results.single.description, '1975–1991');
    });

    test('the country alone is enough of a place', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{
          "id": "x", "name": "Kraftwerk", "area": {"name": "Germany"}
        }]}
      ''');

      expect(results.single.description, 'Germany');
    });

    test('an artist MusicBrainz knows nothing else about has no about', () {
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{"id": "x", "name": "Unknown"}]}
      ''');

      expect(results.single.description, isNull);
    });

    test('nothing more is fetched for the artist that was picked', () async {
      const source = MusicBrainzSource(userAgent: 'Memini/1.0');
      final results = MusicBrainzSource.parseSearch('''
        {"artists": [{"id": "x", "name": "Wilco", "type": "Group"}]}
      ''');

      // No client is given, so a request here would throw rather than pass.
      expect(await source.details(results.single), same(results.single));
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
