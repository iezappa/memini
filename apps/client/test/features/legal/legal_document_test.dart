import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/features/legal/domain/legal_document.dart';

void main() {
  group('LegalDocument.parse', () {
    test('reads headings, paragraphs and bullets in order', () {
      final doc = LegalDocument.parse('''
# Title

Last updated: today

## Section

- first **bold** item
- second item
  continued

A paragraph
over two lines.
''');

      expect(doc.title, 'Title');
      expect(doc.blocks.map((b) => b.kind), [
        LegalBlockKind.paragraph,
        LegalBlockKind.heading,
        LegalBlockKind.bullet,
        LegalBlockKind.bullet,
        LegalBlockKind.paragraph,
      ]);
      expect(doc.blocks[2].text, 'first bold item');
      expect(doc.blocks[3].text, 'second item continued');
      expect(doc.blocks[4].text, 'A paragraph over two lines.');
    });

    test('turns links and code spans into their plain text', () {
      final doc = LegalDocument.parse(
        '# T\n\nSee [TMDB](https://www.themoviedb.org/) and `localStorage`.',
      );

      expect(
        doc.blocks.single.text,
        'See TMDB (https://www.themoviedb.org/) and localStorage.',
      );
    });

    test('keeps a nested bullet as a bullet', () {
      final doc = LegalDocument.parse('# T\n\n- top\n  - nested');

      expect(doc.blocks.map((b) => b.text), ['top', 'nested']);
    });
  });

  group('bundled copies', () {
    // The app shows the policy offline from its own assets. The repository
    // root holds the canonical English text the README and CI point at, so
    // the bundled copy must never drift from it.
    for (final name in ['PRIVACY', 'TERMS']) {
      test('$name.md at the repo root matches the bundled English copy', () {
        final root = File('../../$name.md').readAsStringSync();
        final bundled = File('assets/legal/${name.toLowerCase()}_en.md')
            .readAsStringSync();

        expect(bundled, root);
      });
    }

    for (final path in [
      'assets/legal/privacy_en.md',
      'assets/legal/privacy_es.md',
      'assets/legal/terms_en.md',
      'assets/legal/terms_es.md',
    ]) {
      test(
        '$path names the developer and the contact, with no placeholder',
        () {
          final text = File(path).readAsStringSync();

          expect(text, isNot(contains('{{')));
          expect(text, contains('Zeke Zappa Developments (iezappa)'));
          expect(text, contains('https://github.com/iezappa/memini/issues'));
          expect(LegalDocument.parse(text).blocks, isNotEmpty);
        },
      );
    }

    test('the privacy policy discloses every lookup service', () {
      for (final path in [
        'assets/legal/privacy_en.md',
        'assets/legal/privacy_es.md',
      ]) {
        final text = File(path).readAsStringSync();
        for (final service in ['TMDB', 'RAWG', 'MusicBrainz']) {
          expect(text, contains(service), reason: '$path misses $service');
        }
      }
    });
  });
}
