import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/backup/data/backup_service.dart';
import 'package:memini/features/backup/domain/backup_document.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/rooms/domain/room_repository.dart';
import 'package:memini/features/shared/photo_storage.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late Directory documents;
  late PhotoStorage photos;
  late BackupService service;
  late DriftRoomRepository rooms;

  setUp(() {
    db = memoryDatabase();
    documents = Directory.systemTemp.createTempSync('memini_archive_');
    photos = PhotoStorage(documentsDirectory: () async => documents);
    service = BackupService(db, photos: photos);
    rooms = DriftRoomRepository(db);
  });
  tearDown(() async {
    await db.close();
    if (documents.existsSync()) documents.deleteSync(recursive: true);
  });

  final pixels = Uint8List.fromList(List<int>.generate(64, (i) => i));

  Future<String> storedPhoto() async {
    final picked = File('${documents.path}/picked.jpg')
      ..writeAsBytesSync(pixels);
    final path = (await photos.store(picked.path))!;
    picked.deleteSync();
    return path;
  }

  Future<void> seedRoom({String? photoPath}) => rooms.create(
    RoomDraft(
      title: 'The Vault',
      photoPath: photoPath,
      happenedOn: DateTime(2026, 3, 14),
      escaped: true,
    ),
  );

  Future<Room> onlyRoom() async =>
      (await rooms.list(const RoomFilter())).single;

  test('exports one zip file holding the document and the photos', () async {
    await seedRoom(photoPath: await storedPhoto());

    final export = await service.exportArchive();
    final archive = ZipDecoder().decodeBytes(export.bytes);

    expect(archive.findFile('backup.json'), isNotNull);
    expect(
      archive.files.where((f) => f.name.startsWith('photos/')),
      hasLength(1),
    );
    expect(export.missingPhotos, 0);
  });

  test('round-trips an entry with its photo', () async {
    await seedRoom(photoPath: await storedPhoto());
    final export = await service.exportArchive();

    // A different device: nothing stored, not even the photo folder.
    await service.eraseEverything();
    await photos.removeAll();

    final document = await service.importFile(export.bytes);

    expect(document.rooms, hasLength(1));
    final restored = await onlyRoom();
    expect(restored.photoPath, isNotNull);
    expect(restored.photoPath, startsWith(documents.path));
    expect(File(restored.photoPath!).readAsBytesSync(), pixels);
  });

  test('a missing photo file is left out, not a failed export', () async {
    await seedRoom(photoPath: '${documents.path}/room_photos/gone.jpg');

    final export = await service.exportArchive();

    expect(export.missingPhotos, 1);
    await service.eraseEverything();
    await service.importFile(export.bytes);
    expect((await onlyRoom()).photoPath, isNull);
  });

  test('still imports an old plain JSON backup, which has no photos', () async {
    await seedRoom();
    final legacy = (await service.exportJson()).replaceAll(
      RegExp(r'"version": \d+'),
      '"version": 2',
    );
    await service.eraseEverything();

    final document = await service.importFile(utf8.encode(legacy));

    expect(document.version, 2);
    expect((await onlyRoom()).title, 'The Vault');
  });

  test('writes the current format version', () async {
    await seedRoom();
    final export = await service.exportArchive();
    final json = utf8.decode(
      ZipDecoder().decodeBytes(export.bytes).findFile('backup.json')!.content,
    );

    expect(BackupDocument.currentVersion, 3);
    expect(jsonDecode(json)['version'], 3);
  });

  test('refuses a zip that is not a Memini backup, touching nothing', () async {
    await seedRoom();
    final stranger = ZipEncoder().encodeBytes(
      Archive()..addFile(ArchiveFile.bytes('notes.txt', utf8.encode('hi'))),
    );

    await expectLater(
      service.importFile(stranger),
      throwsA(isA<BackupFormatException>()),
    );
    expect(await rooms.list(const RoomFilter()), hasLength(1));
  });

  test('refuses bytes that are neither a zip nor JSON', () async {
    await expectLater(
      service.importFile(Uint8List.fromList([0, 159, 146, 150])),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('restoring drops the photos of the data it replaced', () async {
    final old = await storedPhoto();
    await seedRoom(photoPath: old);
    await service.eraseEverything();
    await seedRoom(photoPath: await storedPhoto());
    final export = await service.exportArchive();

    await service.importFile(export.bytes);

    expect(File(old).existsSync(), isFalse);
    expect(File((await onlyRoom()).photoPath!).existsSync(), isTrue);
  });
}
