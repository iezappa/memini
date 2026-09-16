import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'backup_document.dart';

/// The backup as one file: `backup.json` plus a `photos/` folder, zipped.
///
/// One zip rather than photos base64-encoded inside the JSON: base64 grows
/// every photo by a third and holds the whole thing as one string while it is
/// parsed, and a zip stays openable by hand with any archive tool.
///
/// Framework-free, like [BackupDocument].
abstract final class BackupArchive {
  static const documentName = 'backup.json';
  static const photoFolder = 'photos/';

  /// The entry lists whose items carry a `photoPath`.
  static const entryLists = ['rooms', 'meals', 'gigs', 'viewings', 'games'];

  static Uint8List encode(String json, Map<String, Uint8List> photos) {
    final archive = Archive()
      ..addFile(ArchiveFile.bytes(documentName, utf8.encode(json)));
    for (final photo in photos.entries) {
      archive.addFile(ArchiveFile.bytes(photo.key, photo.value));
    }
    return ZipEncoder().encodeBytes(archive);
  }

  /// Whether [bytes] start like a zip file, as opposed to plain JSON.
  static bool looksLikeZip(List<int> bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04;

  /// The JSON document and every photo inside a zip.
  ///
  /// Throws [BackupFormatException] for a zip that cannot be read or holds no
  /// backup document.
  static ({String json, Map<String, Uint8List> photos}) decode(
    List<int> bytes,
  ) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const BackupFormatException('not-a-zip');
    }

    final document = archive.findFile(documentName);
    if (document == null) {
      throw const BackupFormatException('missing-document');
    }

    final String json;
    try {
      json = utf8.decode(document.content);
    } on FormatException {
      throw const BackupFormatException('not-json');
    }

    return (
      json: json,
      photos: {
        for (final file in archive.files)
          if (file.isFile && file.name.startsWith(photoFolder))
            file.name: file.content,
      },
    );
  }
}
