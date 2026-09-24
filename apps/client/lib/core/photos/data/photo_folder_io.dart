import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/photo_folder.dart';

/// A real folder on a real filesystem, for the desktop and mobile builds.
///
/// The path is all that is kept, because a path is all the platform gives:
/// the folder may be renamed, unplugged or deleted between launches, and the
/// only way to find out is to try.
class IoPhotoFolder implements PhotoFolder {
  IoPhotoFolder(this._prefs);

  final SharedPreferences _prefs;

  static const pathKey = 'photos.folder';

  @override
  bool get isSupported => true;

  @override
  Future<String?> choose() async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null) return null;

    await _prefs.setString(pathKey, path);
    return path;
  }

  @override
  Future<String?> remembered() async {
    final path = _prefs.getString(pathKey);
    if (path == null) return null;

    if (!Directory(path).existsSync()) {
      throw const PhotoFolderException(PhotoFolderProblem.folderGone);
    }
    return path;
  }

  @override
  Future<void> write(String fileName, Uint8List bytes) async {
    final path = _prefs.getString(pathKey);
    if (path == null) {
      throw const PhotoFolderException(PhotoFolderProblem.folderGone);
    }

    final folder = Directory(path);
    if (!folder.existsSync()) {
      throw const PhotoFolderException(PhotoFolderProblem.folderGone);
    }

    try {
      // Written beside its final name and moved into place, so a copy
      // interrupted halfway — a full disk, a laptop lid — cannot leave a
      // truncated file wearing the name of a good one.
      final separator = Platform.pathSeparator;
      final scratch = File('${folder.path}$separator.$fileName');
      await scratch.writeAsBytes(bytes, flush: true);
      await scratch.rename('${folder.path}$separator$fileName');
    } on FileSystemException {
      throw const PhotoFolderException(PhotoFolderProblem.failed);
    }
  }

  @override
  Future<void> forget() => _prefs.remove(pathKey).then((_) {});
}

/// The folder for this build. See `photo_folder_platform.dart`.
PhotoFolder photoFolderFor(SharedPreferences prefs) => IoPhotoFolder(prefs);
