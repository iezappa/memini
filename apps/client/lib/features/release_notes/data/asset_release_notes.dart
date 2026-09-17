import 'package:flutter/services.dart';

import '../domain/release_notes.dart';

/// Reads the release notes bundled with the app, one file per language.
class AssetReleaseNotes {
  const AssetReleaseNotes(this._bundle);

  final AssetBundle _bundle;

  /// Mirrors the ARB files.
  static const supportedLanguages = {'en', 'es'};

  static String pathFor(String languageCode) {
    final language = supportedLanguages.contains(languageCode)
        ? languageCode
        : 'en';
    return 'assets/release_notes/$language.json';
  }

  Future<ReleaseNotes> load(String languageCode) async =>
      ReleaseNotes.parse(await _bundle.loadString(pathFor(languageCode)));
}
