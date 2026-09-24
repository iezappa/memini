import 'dart:typed_data';

/// A picture belonging to one entry.
class EntryPhoto {
  const EntryPhoto({
    required this.id,
    required this.ownerId,
    required this.bytes,
    required this.mimeType,
  });

  final String id;
  final String ownerId;
  final Uint8List bytes;
  final String mimeType;

  /// What to call the copy written into the backup folder.
  ///
  /// The id is the name: it is already unique, and a photo named after the
  /// entry would collide the moment a second one is added to it.
  String get fileName => '$id.${extensionFor(mimeType)}';

  /// The handful of formats a camera or a phone gallery produces.
  ///
  /// Anything else keeps a generic extension rather than being refused:
  /// the app shows it from the bytes either way, and the extension only
  /// decides what a file manager makes of the copy in the folder.
  static String extensionFor(String mimeType) => switch (mimeType) {
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/heic' => 'heic',
    'image/gif' => 'gif',
    _ => 'img',
  };
}

/// Where an entry's pictures are kept.
abstract interface class PhotoRepository {
  Future<List<EntryPhoto>> forOwner(String ownerId);

  /// Every picture in the store, for filling a folder chosen after the fact.
  Future<List<EntryPhoto>> all();

  Future<EntryPhoto> add({
    required String ownerId,
    required Uint8List bytes,
    required String mimeType,
  });

  Future<void> delete(String id);

  /// Drops every picture of an entry that is being deleted.
  Future<void> deleteForOwner(String ownerId);
}
