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
  const PhotoStorage({
    this.documentsDirectory = getApplicationDocumentsDirectory,
  });

  /// Where the photo folder lives. Injectable so tests can use a temporary
  /// directory instead of a platform channel.
  final Future<Directory> Function() documentsDirectory;

  static const _folder = 'room_photos';

  Future<Directory> _photoFolder() async =>
      Directory('${(await documentsDirectory()).path}/$_folder');

  /// Returns the stored path, or null on web where there is no file system
  /// to copy into.
  Future<String?> store(String sourcePath) async {
    if (kIsWeb) return null;

    final folder = await _photoFolder();
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

      final folder = await _photoFolder();
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

  /// Deletes every photo the app copied in, orphans included.
  Future<void> removeAll() async {
    if (kIsWeb) return;

    final folder = await _photoFolder();
    if (await folder.exists()) await folder.delete(recursive: true);
  }

  /// The bytes of a stored photo, or null when there is none to read — on
  /// web, or when the file is gone.
  Future<Uint8List?> read(String path) async {
    if (kIsWeb) return null;

    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  /// Writes [bytes] as a new photo, as [store] does for a picked file.
  /// Returns null on web, where there is no file system to write to.
  Future<String?> storeBytes(
    Uint8List bytes, {
    String extension = '.jpg',
  }) async {
    if (kIsWeb) return null;

    final folder = await _photoFolder();
    if (!await folder.exists()) await folder.create(recursive: true);

    final target =
        '${folder.path}/${DateTime.now().microsecondsSinceEpoch}$extension';
    await File(target).writeAsBytes(bytes);
    return target;
  }

  /// Deletes every stored photo whose path is not in [keep].
  ///
  /// Used after a restore, which replaces every entry: the photos of the
  /// entries it replaced would otherwise stay on disk with nothing pointing
  /// at them.
  Future<void> removeAllExcept(Set<String> keep) async {
    if (kIsWeb) return;

    final folder = await _photoFolder();
    if (!await folder.exists()) return;
    await for (final entity in folder.list()) {
      if (entity is File && !keep.contains(entity.path)) {
        await entity.delete();
      }
    }
  }
}
