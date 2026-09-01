import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Copies picked images into the app's own documents directory.
///
/// The picker hands back a path in a cache or a content provider that the OS
/// is free to purge; a room photo has to outlive that, so it is copied in and
/// only the copy's path is stored.
class PhotoStorage {
  const PhotoStorage();

  static const _folder = 'room_photos';

  /// Returns the stored path, or null on web where there is no file system
  /// to copy into.
  Future<String?> store(String sourcePath) async {
    if (kIsWeb) return null;

    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory('${documents.path}/$_folder');
    if (!await folder.exists()) await folder.create(recursive: true);

    final extension = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.'))
        : '.jpg';
    final target =
        '${folder.path}/${DateTime.now().microsecondsSinceEpoch}$extension';

    await File(sourcePath).copy(target);
    return target;
  }

  /// Downloads remote cover art into the same folder, so an enriched entry
  /// keeps its image offline like every other one.
  ///
  /// Returns null on web, and on any failure: cover art is a nicety, and a
  /// flaky download must never cost the owner the entry they were saving.
  Future<String?> storeFromUrl(String url, {http.Client? client}) async {
    if (kIsWeb) return null;

    final connection = client ?? http.Client();
    try {
      final response = await connection.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final documents = await getApplicationDocumentsDirectory();
      final folder = Directory('${documents.path}/$_folder');
      if (!await folder.exists()) await folder.create(recursive: true);

      final extension = _extensionOf(url);
      final target =
          '${folder.path}/${DateTime.now().microsecondsSinceEpoch}$extension';

      await File(target).writeAsBytes(response.bodyBytes);
      return target;
    } catch (_) {
      return null;
    } finally {
      if (client == null) connection.close();
    }
  }

  /// The extension from the URL path only — a query string must not end up
  /// in the file name.
  static String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot == -1 || path.length - dot > 5) return '.jpg';
    return path.substring(dot);
  }

  /// Deletes a stored photo. Missing files are not an error: the row may have
  /// outlived the file after a restore from a backup made on another device.
  Future<void> remove(String? path) async {
    if (kIsWeb || path == null) return;

    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
