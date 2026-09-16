import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Deletes the folder where builds before schema v3 copied entry photos.
///
/// Memini no longer keeps photos, and the migration to v3 drops the paths that
/// pointed at these files, so nothing can reach them any more. Best effort:
/// leftover files only cost space, and failing here must never stop the app.
Future<void> deleteLegacyPhotos({
  Future<Directory> Function() documentsDirectory =
      getApplicationDocumentsDirectory,
}) async {
  if (kIsWeb) return;

  try {
    final folder = Directory(
      '${(await documentsDirectory()).path}/room_photos',
    );
    if (await folder.exists()) await folder.delete(recursive: true);
  } catch (_) {
    // Nothing to recover: the files are unreachable either way.
  }
}
