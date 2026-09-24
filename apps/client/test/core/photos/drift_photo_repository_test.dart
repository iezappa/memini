import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/photos/data/drift_photo_repository.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';

void main() {
  late AppDatabase db;
  late DriftPhotoRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftPhotoRepository(db, now: () => DateTime(2026, 5, 1));
  });
  tearDown(() => db.close());

  Uint8List bytes(int value) => Uint8List.fromList([value, value, value]);

  test('keeps the bytes, not a path to them', () async {
    await repository.add(
      ownerId: 'room-1',
      bytes: bytes(7),
      mimeType: 'image/png',
    );

    final stored = await repository.forOwner('room-1');

    expect(stored, hasLength(1));
    expect(stored.single.bytes, bytes(7));
    expect(stored.single.mimeType, 'image/png');
  });

  test('names the copy after the picture, not after the entry', () async {
    final photo = await repository.add(
      ownerId: 'room-1',
      bytes: bytes(1),
      mimeType: 'image/png',
    );
    final second = await repository.add(
      ownerId: 'room-1',
      bytes: bytes(2),
      mimeType: 'image/png',
    );

    // Two pictures of one entry, so a name taken from the entry would put
    // the second on top of the first in the folder.
    expect(photo.fileName, isNot(second.fileName));
    expect(photo.fileName, endsWith('.png'));
  });

  test('hands back only the pictures of the entry asked for', () async {
    await repository.add(
      ownerId: 'room-1',
      bytes: bytes(1),
      mimeType: 'image/jpeg',
    );
    await repository.add(
      ownerId: 'meal-1',
      bytes: bytes(2),
      mimeType: 'image/jpeg',
    );

    expect(await repository.forOwner('room-1'), hasLength(1));
    expect(await repository.all(), hasLength(2));
  });

  test('removes one picture without touching its neighbours', () async {
    final photo = await repository.add(
      ownerId: 'room-1',
      bytes: bytes(1),
      mimeType: 'image/jpeg',
    );
    await repository.add(
      ownerId: 'room-1',
      bytes: bytes(2),
      mimeType: 'image/jpeg',
    );

    await repository.delete(photo.id);

    expect(await repository.forOwner('room-1'), hasLength(1));
  });

  test('deleting the entry takes its pictures with it', () async {
    // No foreign key ties a photo to one of the five tables, so nothing in
    // SQLite does this on its own: an orphan would keep its bytes in the
    // store with no screen able to reach it.
    final rooms = DriftRoomRepository(db);
    final room = await rooms.create(
      RoomDraft(
        title: 'The Vault',
        happenedOn: DateTime(2026, 3, 14),
        escaped: true,
      ),
    );
    await repository.add(
      ownerId: room.id,
      bytes: bytes(1),
      mimeType: 'image/png',
    );

    await rooms.delete(room.id);

    expect(await repository.all(), isEmpty);
  });

  test('drops every picture of an entry that is being deleted', () async {
    await repository.add(
      ownerId: 'room-1',
      bytes: bytes(1),
      mimeType: 'image/jpeg',
    );
    await repository.add(
      ownerId: 'room-1',
      bytes: bytes(2),
      mimeType: 'image/jpeg',
    );

    await repository.deleteForOwner('room-1');

    expect(await repository.forOwner('room-1'), isEmpty);
  });
}
