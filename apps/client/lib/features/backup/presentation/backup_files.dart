import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Where backup files leave the app and come back in.
///
/// A port so that every place that exports or imports — settings, the
/// storage banner, the recovery screen — can be tested without a share sheet
/// or a file picker.
abstract interface class BackupFiles {
  /// Hands [files] (name to contents) to the platform. False when it could
  /// not be done.
  Future<bool> save(Map<String, Uint8List> files);

  /// The contents of a file the user picked, or null when they backed out.
  Future<Uint8List?> open();
}

class PlatformBackupFiles implements BackupFiles {
  const PlatformBackupFiles();

  @override
  Future<bool> save(Map<String, Uint8List> files) async {
    final List<XFile> shared;
    if (kIsWeb) {
      // No file system to write to: the browser gets the bytes directly.
      shared = [
        for (final entry in files.entries)
          XFile.fromData(entry.value, name: entry.key),
      ];
    } else {
      final directory = await getApplicationDocumentsDirectory();
      shared = <XFile>[];
      for (final entry in files.entries) {
        final file = File('${directory.path}/${entry.key}');
        await file.writeAsBytes(entry.value);
        shared.add(XFile(file.path));
      }
    }

    await SharePlus.instance.share(
      ShareParams(
        files: shared,
        fileNameOverrides: kIsWeb ? files.keys.toList() : null,
        subject: files.keys.first,
      ),
    );
    return true;
  }

  @override
  Future<Uint8List?> open() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      // zip is the backup since format v3; json is every backup before it.
      allowedExtensions: const ['zip', 'json'],
    );
    return file?.readAsBytes();
  }
}

final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const PlatformBackupFiles(),
);
