import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../shared/widgets.dart';
import '../data/asset_legal_documents.dart';
import '../domain/legal_document.dart';

/// Shows a bundled legal document in the interface language.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({super.key, required this.type});

  final LegalDocumentType type;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  Future<LegalDocument>? _document;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _document ??= AssetLegalDocuments(DefaultAssetBundle.of(context))
        .load(widget.type, Localizations.localeOf(context).languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LegalDocument>(
      future: _document,
      builder: (context, snapshot) {
        final document = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: Text(document?.title ?? '')),
          body: SafeArea(
            child: ContentColumn(
              child: document == null
                  ? const Center(child: CircularProgressIndicator())
                  : SelectionArea(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: Gap.md),
                        children: [
                          for (final block in document.blocks)
                            _Block(block: block),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});

  final LegalBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.kind) {
      case LegalBlockKind.heading:
        return Padding(
          padding: const EdgeInsets.only(top: Gap.md, bottom: Gap.sm),
          child: Semantics(
            header: true,
            child: Text(block.text, style: context.text.titleMedium),
          ),
        );
      case LegalBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: Gap.sm),
          child: Text(block.text, style: context.text.bodyMedium),
        );
      case LegalBlockKind.bullet:
        return Padding(
          padding: EdgeInsets.only(left: Gap.md * block.depth, bottom: Gap.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: context.text.bodyMedium),
              Expanded(child: Text(block.text, style: context.text.bodyMedium)),
            ],
          ),
        );
    }
  }
}
