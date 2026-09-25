import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/maps/domain/map_point.dart';

void main() {
  /// Buenos Aires, Palermo — near enough to where the test data eats.
  const there = MapPoint(-34.5883, -58.4262);

  group('a link with the place in it', () {
    test('Google, copied from the address bar of a place page', () {
      expect(
        parseMapLink(
          'https://www.google.com/maps/place/Don+Julio/'
          '@-34.5883,-58.4262,17z/data=!3m1!4b1',
        ),
        there,
      );
    });

    test('Google, where the pin and the viewport disagree', () {
      // `!3d!4d` is the place itself; `@` is wherever the map happened to be
      // when the link was copied. The place wins.
      expect(
        parseMapLink(
          'https://www.google.com/maps/place/X/@-34.9,-58.9,14z/'
          'data=!4m6!3m5!1s0x95!8m2!3d-34.5883!4d-58.4262',
        ),
        there,
      );
    });

    test('Google, the share-a-search form', () {
      expect(
        parseMapLink(
          'https://www.google.com/maps/search/?api=1&query=-34.5883,-58.4262',
        ),
        there,
      );
    });

    test('a query that arrived url-encoded', () {
      expect(
        parseMapLink('https://maps.google.com/?q=-34.5883%2C-58.4262'),
        there,
      );
    });

    test('Apple Maps', () {
      expect(
        parseMapLink('https://maps.apple.com/?ll=-34.5883,-58.4262&q=Don'),
        there,
      );
    });

    test('OpenStreetMap, with its marker', () {
      expect(
        parseMapLink(
          'https://www.openstreetmap.org/?mlat=-34.5883&mlon=-58.4262'
          '#map=17/-34.1/-58.1',
        ),
        there,
      );
    });

    test('OpenStreetMap, from the address bar', () {
      expect(
        parseMapLink('https://www.openstreetmap.org/#map=19/-34.5883/-58.4262'),
        there,
      );
    });

    test('a geo: URI, which is what a phone shares', () {
      expect(parseMapLink('geo:-34.5883,-58.4262'), there);
    });

    test('two numbers pasted on their own', () {
      expect(parseMapLink('-34.5883, -58.4262'), there);
    });
  });

  group('a link with nothing in it', () {
    test('a shortened link carries no position', () {
      // The place lives behind a redirect, and following it would mean
      // asking the shortener — which is the one thing this must not do.
      expect(parseMapLink('https://maps.app.goo.gl/aBcDeF12'), isNull);
    });

    test('a plain web address is not a place', () {
      expect(parseMapLink('https://donjulio.com.ar'), isNull);
    });

    test('nothing at all', () {
      expect(parseMapLink(null), isNull);
      expect(parseMapLink('   '), isNull);
    });

    test('numbers that are not on the earth are not a place', () {
      expect(parseMapLink('geo:-91.0,-58.4262'), isNull);
      expect(parseMapLink('-34.5883,-190.0'), isNull);
    });

    test('a null island is a parser failing, not a place anyone ate', () {
      expect(parseMapLink('0.0,0.0'), isNull);
    });
  });
}
