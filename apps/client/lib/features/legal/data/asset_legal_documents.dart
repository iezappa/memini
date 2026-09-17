import 'package:flutter/services.dart';

import '../domain/legal_document.dart';

enum LegalDocumentType { privacy, terms }

/// Reads the privacy policy and the terms bundled with the app, so they open
/// without a connection. English is the fallback for any other language.
class AssetLegalDocuments {
  const AssetLegalDocuments(this._bundle);

  final AssetBundle _bundle;

  static const supportedLanguages = {'en', 'es'};

  static String pathFor(LegalDocumentType type, String languageCode) {
    final language = supportedLanguages.contains(languageCode)
        ? languageCode
        : 'en';
    return 'assets/legal/${type.name}_$language.md';
  }

  Future<LegalDocument> load(
    LegalDocumentType type,
    String languageCode,
  ) async => LegalDocument.parse(
    await _bundle.loadString(pathFor(type, languageCode)),
  );
}
