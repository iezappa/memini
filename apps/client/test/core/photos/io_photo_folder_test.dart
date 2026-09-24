@TestOn('vm')
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/photos/data/photo_folder_io.dart';
import 'package:memini/core/photos/domain/photo_folder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory folder;
  late SharedPreferences prefs;
  late IoPhotoFolder target;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    folder = await Directory.systemTemp.createTemp('memini-photos');
    await prefs.setString(IoPhotoFolder.pathKey, folder.path);
    target = IoPhotoFolder(prefs);
  });
  tearDown(() {
    if (folder.existsSync()) folder.deleteSync(recursive: true);
  });

  File inFolder(String name) =>
      File('${folder.path}${Platform.pathSeparator}$name');

  final bytes = Uint8List.fromList([137, 80, 78, 71]);

  test('writes the picture into the folder it was given', () async {
    await target.write('a1b2.png', bytes);

    expect(inFolder('a1b2.png').readAsBytesSync(), bytes);
  });

  test('replaces a copy of the same name', () async {
    await target.write('a1b2.png', Uint8List.fromList([1]));
    await target.write('a1b2.png', Uint8List.fromList([2]));

    expect(inFolder('a1b2.png').readAsBytesSync(), [2]);
  });

  test('leaves no half-written file behind under the real name', () async {
    await target.write('a1b2.png', bytes);

    // The scratch name it writes through, which the rename clears away.
    expect(inFolder('.a1b2.png').existsSync(), isFalse);
  });

  test('remembers the folder between launches', () async {
    expect(await target.remembered(), folder.path);
  });

  test('says nothing was chosen when nothing was', () async {
    SharedPreferences.setMockInitialValues({});
    final empty = IoPhotoFolder(await SharedPreferences.getInstance());

    expect(await empty.remembered(), isNull);
  });

  test('reports a folder that is no longer there', () async {
    folder.deleteSync(recursive: true);

    expect(
      () => target.remembered(),
      throwsA(
        isA<PhotoFolderException>().having(
          (e) => e.problem,
          'problem',
          PhotoFolderProblem.folderGone,
        ),
      ),
    );
  });

  test('refuses to write into a folder that is gone', () async {
    folder.deleteSync(recursive: true);

    expect(
      () => target.write('a1b2.png', bytes),
      throwsA(isA<PhotoFolderException>()),
    );
  });

  test('forgetting leaves the copies where they are', () async {
    await target.write('a1b2.png', bytes);

    await target.forget();

    expect(await target.remembered(), isNull);
    expect(inFolder('a1b2.png').existsSync(), isTrue);
  });
}
