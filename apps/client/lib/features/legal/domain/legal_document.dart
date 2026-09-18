/// The kinds of block a legal document is made of.
enum LegalBlockKind { heading, paragraph, bullet }

class LegalBlock {
  const LegalBlock(this.kind, this.text, {this.depth = 0});

  final LegalBlockKind kind;

  /// Plain text: emphasis markers dropped, links spelled out.
  final String text;

  /// Nesting level of a bullet; zero for everything else.
  final int depth;
}

/// A privacy policy or terms document, read from the small subset of
/// Markdown the files in `assets/legal/` use.
///
/// A full Markdown package would be a dependency for four files that only
/// ever hold headings, paragraphs and bullets. Parsing that subset here keeps
/// the documents readable offline with nothing new in the lockfile.
class LegalDocument {
  const LegalDocument({required this.title, required this.blocks});

  final String title;
  final List<LegalBlock> blocks;

  factory LegalDocument.parse(String source) {
    var title = '';
    final blocks = <LegalBlock>[];

    LegalBlockKind? kind;
    var depth = 0;
    final buffer = <String>[];

    void flush() {
      if (kind != null && buffer.isNotEmpty) {
        blocks.add(LegalBlock(kind!, _inline(buffer.join(' ')), depth: depth));
      }
      kind = null;
      depth = 0;
      buffer.clear();
    }

    for (final raw in source.split('\n')) {
      final line = raw.trimRight();
      final trimmed = line.trimLeft();

      if (trimmed.isEmpty) {
        flush();
        continue;
      }
      if (trimmed.startsWith('<!--')) continue;
      // The `**English** · [Español](X.es.md)` line links the published
      // translations on GitHub; inside the app the locale already chose.
      if (_languageSwitcher.hasMatch(trimmed)) {
        flush();
        continue;
      }

      if (trimmed.startsWith('#')) {
        flush();
        final level = trimmed.indexOf(RegExp(r'[^#]'));
        final text = _inline(trimmed.substring(level).trim());
        if (level == 1 && title.isEmpty) {
          title = text;
        } else {
          blocks.add(LegalBlock(LegalBlockKind.heading, text));
        }
        continue;
      }

      if (trimmed.startsWith('- ')) {
        flush();
        kind = LegalBlockKind.bullet;
        depth = (line.length - trimmed.length) ~/ 2;
        buffer.add(trimmed.substring(2).trim());
        continue;
      }

      kind ??= LegalBlockKind.paragraph;
      buffer.add(trimmed);
    }
    flush();

    return LegalDocument(title: title, blocks: List.unmodifiable(blocks));
  }

  static final _languageSwitcher = RegExp(
    r'^(\*\*[^*]+\*\*|\[[^\]]+\]\([^)]+\.md\))'
    r'( · (\*\*[^*]+\*\*|\[[^\]]+\]\([^)]+\.md\)))+$',
  );

  static String _inline(String text) => text
      .replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
        (m) => '${m[1]} (${m[2]})',
      )
      .replaceAll('**', '')
      .replaceAll('`', '');
}
