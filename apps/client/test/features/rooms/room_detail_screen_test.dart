import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/rooms/domain/room_repository.dart';
import 'package:memini/features/rooms/presentation/room_detail_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftRoomRepository rooms;

  setUp(() {
    db = memoryDatabase();
    rooms = DriftRoomRepository(db);
  });
  tearDown(() => db.close());

  Future<Room> logRoom({int? franchiseId}) => rooms.create(
    RoomDraft(
      title: 'The Vault',
      happenedOn: DateTime(2026, 3, 14),
      escaped: true,
      timeLeftMinutes: 4,
      rating: 9.5,
      review: 'Worth it for the last puzzle alone.',
      franchiseId: franchiseId,
    ),
  );

  Future<void> pumpDetail(WidgetTester tester, Room room) async {
    await pumpPushed(tester, RoomDetailScreen(roomId: room.id), database: db);
    // The franchise name arrives from a separate query, so the first frame
    // renders the room with no franchise on it yet.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the room, its score and its review', (tester) async {
    await pumpDetail(tester, await logRoom());

    expect(find.text('The Vault'), findsWidgets);
    expect(find.text('Worth it for the last puzzle alone.'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('resolves the franchise name, which the room only holds by id', (
    tester,
  ) async {
    final franchise = await DriftFranchiseRepository(db)
        .create(const FranchiseDraft(name: 'Enigma Rooms'));

    await pumpDetail(tester, await logRoom(franchiseId: franchise.id));

    // The franchise shares one line with the date, so it is a substring of
    // that line rather than a Text of its own.
    expect(find.textContaining('Enigma Rooms'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('asks before deleting, and names the room it would destroy', (
    tester,
  ) async {
    await pumpDetail(tester, await logRoom());

    await tapDelete(tester);

    expect(
      find.text('Delete "The Vault"? This cannot be undone.'),
      findsOneWidget,
      reason: 'a destructive prompt has to say what it is about to destroy',
    );

    await unmount(tester);
  });

  testWidgets('leaves the room alone when the delete is cancelled', (
    tester,
  ) async {
    await pumpDetail(tester, await logRoom());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // There is no server and no undo: a delete that fires on a cancel takes
    // the entry with it for good.
    expect(await rooms.list(const RoomFilter()), hasLength(1));

    await unmount(tester);
  });

  testWidgets('deletes the room once the delete is confirmed', (tester) async {
    await pumpDetail(tester, await logRoom());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await rooms.list(const RoomFilter()), isEmpty);

    await unmount(tester);
  });
}
