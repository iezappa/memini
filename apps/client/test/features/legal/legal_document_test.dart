import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/features/legal/data/asset_legal_documents.dart';
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

    test('skips the language switcher line, in either language', () {
      for (final switcher in [
        '**English** · [Español](PRIVACY.es.md)',
        '[English](PRIVACY.md) · **Español**',
      ]) {
        final doc = LegalDocument.parse('# T\n\n$switcher\n\nBody');

        expect(doc.blocks.map((b) => b.text), ['Body'], reason: switcher);
      }
    });

    test('keeps a sentence that merely contains a link', () {
      final doc = LegalDocument.parse('# T\n\nSee [the terms](TERMS.md) too.');

      expect(doc.blocks.single.text, 'See the terms (TERMS.md) too.');
    });

    test('keeps a nested bullet as a bullet', () {
      final doc = LegalDocument.parse('# T\n\n- top\n  - nested');

      expect(doc.blocks.map((b) => b.text), ['top', 'nested']);
    });
  });

  group('bundled copies', () {
    // The app shows the policy offline from its own assets. The repository
    // root holds the published text in both languages (English as `NAME.md`,
    // Spanish as `NAME.es.md`), so no bundled copy may drift from it.
    const published = {
      'privacy_en.md': 'PRIVACY.md',
      'privacy_es.md': 'PRIVACY.es.md',
      'terms_en.md': 'TERMS.md',
      'terms_es.md': 'TERMS.es.md',
    };
    for (final MapEntry(key: asset, value: source) in published.entries) {
      test('assets/legal/$asset is byte-identical to $source', () {
        final root = File('../../$source').readAsBytesSync();
        final bundled = File('assets/legal/$asset').readAsBytesSync();

        expect(bundled, root);
      });
    }

    test('the locale picks the bundled file in its language', () {
      for (final type in LegalDocumentType.values) {
        for (final language in ['en', 'es']) {
          final path = AssetLegalDocuments.pathFor(type, language);
          expect(path, 'assets/legal/${type.name}_$language.md');
          expect(File(path).existsSync(), isTrue, reason: path);
        }
      }
    });

    test('falls back to English for a language that is not bundled', () {
      expect(
        AssetLegalDocuments.pathFor(LegalDocumentType.terms, 'fr'),
        'assets/legal/terms_en.md',
      );
    });

    test('the release gate requires both languages, filled in', () {
      final workflow = File('../../.github/workflows/release.yml')
          .readAsStringSync();

      for (final doc in [
        'PRIVACY.md',
        'PRIVACY.es.md',
        'TERMS.md',
        'TERMS.es.md',
      ]) {
        expect(workflow, contains('../../$doc'), reason: doc);
      }
      expect(workflow, contains("grep -q '{{'"));
    });

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
