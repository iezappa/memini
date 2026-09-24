import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/photos/domain/photo_folder.dart';
import 'package:memini/core/photos/presentation/photo_folder_providers.dart';
import 'package:memini/core/photos/presentation/photo_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A folder that keeps what was written to it in memory, and can be told to
/// go wrong the way a real one does.
class FakeFolder implements PhotoFolder {
  FakeFolder({this.name, this.isSupported = true});

  final Map<String, Uint8List> written = {};
  String? name;
  PhotoFolderProblem? problem;
  int chooseCalls = 0;

  @override
  bool isSupported;

  @override
  Future<String?> choose() async {
    chooseCalls++;
    return name = 'Pictures';
  }

  @override
  Future<String?> remembered() async {
    if (problem != null) throw PhotoFolderException(problem!);
    return name;
  }

  @override
  Future<void> write(String fileName, Uint8List bytes) async {
    if (problem != null) throw PhotoFolderException(problem!);
    written[fileName] = bytes;
  }

  @override
  Future<void> forget() async => name = null;
}

void main() {
  late AppDatabase db;
  late FakeFolder folder;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    folder = FakeFolder();
  });
  tearDown(() => db.close());

  Future<ProviderContainer> boot() async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        photoFolderProvider.overrideWithValue(folder),
        photoPickerProvider.overrideWithValue(
          () async => (bytes: Uint8List.fromList([1, 2, 3]), mimeType: 'image/png'),
        ),
      ],
    );
    addTearDown(container.dispose);

    return container;
  }

  test('no folder chosen means nothing is copied anywhere', () async {
    final container = await boot();

    await container.read(photoActionsProvider).attach('room-1');

    expect(folder.written, isEmpty);
    expect(container.read(photoFolderStatusProvider).value?.isOn, isFalse);
  });

  test('a picture added lands in the folder as a file', () async {
    folder.name = 'Pictures';
    final container = await boot();

    // Deliberately without reading the status first: adding a picture is
    // usually what asks for this provider to begin with, and the copy must
    // not be skipped just because the folder is still being looked up.
    await container.read(photoActionsProvider).attach('room-1');

    final photo = (await container
        .read(photoRepositoryProvider)
        .forOwner('room-1')).single;
    expect(folder.written.keys, [photo.fileName]);
    expect(folder.written.values.single, [1, 2, 3]);
  });

  test('choosing a folder fills it with what is already here', () async {
    final container = await boot();
    final repository = container.read(photoRepositoryProvider);
    await repository.add(
      ownerId: 'room-1',
      bytes: Uint8List.fromList([9]),
      mimeType: 'image/png',
    );
    await repository.add(
      ownerId: 'meal-1',
      bytes: Uint8List.fromList([8]),
      mimeType: 'image/jpeg',
    );

    await container.read(photoFolderStatusProvider.notifier).choose();

    expect(folder.written, hasLength(2));
    expect(container.read(photoFolderStatusProvider).value?.isOn, isTrue);
  });

  test('a folder that has been unplugged is reported, not thrown', () async {
    folder.name = 'Pictures';
    final container = await boot();
    await container.read(photoFolderStatusProvider.future);
    folder.problem = PhotoFolderProblem.folderGone;

    // The picture is still added: losing the copy must not lose the photo.
    expect(await container.read(photoActionsProvider).attach('room-1'), isTrue);

    expect(
      await container.read(photoRepositoryProvider).forOwner('room-1'),
      hasLength(1),
    );
    final status = container.read(photoFolderStatusProvider).value!;
    expect(status.problem, PhotoFolderProblem.folderGone);
    expect(status.isOn, isFalse);
  });

  test('a browser that needs the folder allowed again says so', () async {
    folder
      ..name = 'Pictures'
      ..problem = PhotoFolderProblem.needsPermission;
    final container = await boot();

    final status = await container.read(photoFolderStatusProvider.future);

    expect(status.problem, PhotoFolderProblem.needsPermission);
  });

  test('a browser without the API is simply off', () async {
    folder.isSupported = false;
    final container = await boot();

    final status = await container.read(photoFolderStatusProvider.future);

    expect(status.name, isNull);
    expect(status.problem, isNull);
  });

  test('forgetting stops the copies and keeps the ones made', () async {
    folder.name = 'Pictures';
    final container = await boot();
    await container.read(photoActionsProvider).attach('room-1');

    await container.read(photoFolderStatusProvider.notifier).forget();
    await container.read(photoActionsProvider).attach('room-2');

    expect(folder.written, hasLength(1));
    expect(container.read(photoFolderStatusProvider).value?.name, isNull);
  });
}
