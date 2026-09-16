import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/legacy_photos.dart';

void main() {
  late Directory documents;

  setUp(() {
    documents = Directory.systemTemp.createTempSync('memini_legacy_photos_');
  });

  tearDown(() {
    if (documents.existsSync()) documents.deleteSync(recursive: true);
  });

  test('deletes the folder older builds copied photos into', () async {
    final folder = Directory('${documents.path}/room_photos')..createSync();
    File('${folder.path}/1.jpg').writeAsBytesSync([1, 2, 3]);
    final unrelated = File('${documents.path}/keep.txt')..writeAsStringSync('');

    await deleteLegacyPhotos(documentsDirectory: () async => documents);

    expect(folder.existsSync(), isFalse);
    expect(unrelated.existsSync(), isTrue);
  });

  test('does nothing when there is no such folder', () async {
    await deleteLegacyPhotos(documentsDirectory: () async => documents);

    expect(documents.existsSync(), isTrue);
  });

  test('swallows a failure to find the documents directory', () async {
    await expectLater(
      deleteLegacyPhotos(
        documentsDirectory: () async => throw const FileSystemException('x'),
      ),
      completes,
    );
  });
}
