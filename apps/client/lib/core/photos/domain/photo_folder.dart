import 'dart:typed_data';

/// What can go wrong between the app and the folder it was given.
///
/// Three answers rather than one, because the owner can do something
/// different about each: find the folder again, grant the permission again,
/// or simply try once more.
enum PhotoFolderProblem {
  /// Picked once and not there now — renamed, unplugged, deleted, or a
  /// browser that no longer holds the grant at all.
  folderGone,

  /// The browser still has the handle but wants the owner to say yes again.
  /// Nothing is written until they do, and saying so beats failing quietly.
  needsPermission,

  /// The write itself failed: a full disk, a file open elsewhere.
  failed,
}

class PhotoFolderException implements Exception {
  const PhotoFolderException(this.problem);

  final PhotoFolderProblem problem;

  @override
  String toString() => 'PhotoFolderException(${problem.name})';
}

/// A folder on the device that the app may keep copying photos into.
///
/// A port, because what a folder is differs by platform in a way the rest of
/// the app should never see. On the desktop it is a path. In a browser it is
/// a handle the user granted, which can be stored but whose permission may
/// have to be asked for again, and which some browsers do not offer at all.
///
/// This exists because photographs are deliberately absent from the backup
/// JSON — a file you can mail yourself stops being one the moment it carries
/// pictures. The bytes live in the store so the app can show them offline;
/// the copy in this folder is what survives the app being uninstalled, and
/// it is an ordinary image file in an ordinary folder, openable by anything.
abstract interface class PhotoFolder {
  /// Whether this build can hold on to a folder between launches.
  ///
  /// False in a browser with no File System Access API, where the only way
  /// out of the page is the download bar and a download is not a copy that
  /// happens by itself.
  bool get isSupported;

  /// Asks the user to pick one. Returns what to call it on screen, or null
  /// if they backed out.
  Future<String?> choose();

  /// The folder picked before, if it is still there and still allowed.
  ///
  /// Returns null when nothing was ever picked. Throws
  /// [PhotoFolderException] when one was picked and cannot be used now,
  /// because those are different answers: the first is a feature switched
  /// off, the second is a promise being broken.
  Future<String?> remembered();

  /// Writes a picture into it, replacing one of the same name.
  Future<void> write(String fileName, Uint8List bytes);

  /// Forgets the folder. The copies already written stay where they are.
  Future<void> forget();
}
