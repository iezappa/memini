import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asset_release_notes.dart';
import '../domain/release_notes.dart';

/// Where bundled files are read from. Overridden in tests.
final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

/// The release notes in one language; keyed by language because the owner can
/// switch it without restarting.
final releaseNotesProvider = FutureProvider.family<ReleaseNotes, String>(
  (ref, language) =>
      AssetReleaseNotes(ref.watch(assetBundleProvider)).load(language),
);
