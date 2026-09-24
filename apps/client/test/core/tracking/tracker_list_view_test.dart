import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/photos/data/drift_photo_repository.dart';
import 'package:memini/core/tracking/presentation/tracker_card.dart';
import 'package:memini/core/tracking/presentation/tracker_tile.dart';
import 'package:memini/core/tracking/presentation/tracking_view.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/rooms/presentation/room_list_screen.dart';

import '../../support/harness.dart';

/// One transparent pixel, so `Image.memory` has something real to decode.
final _png = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
    'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

/// The list opens on a spinner whose animation never stops, so pumpAndSettle
/// would wait for it forever.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<List<Room>> addRooms(int count) async {
    final repository = DriftRoomRepository(db);
    final rooms = <Room>[];
    for (var i = 0; i < count; i++) {
      rooms.add(
        await repository.create(
          RoomDraft(
            title: 'Room ${i.toString().padLeft(2, '0')}',
            // A day apart each, so the default ordering is stable and the
            // page a room lands on is predictable.
            happenedOn: DateTime(2026, 1, 1).add(Duration(days: i)),
            escaped: true,
          ),
        ),
      );
    }

    return rooms;
  }

  Future<void> pump(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    useTallSurface(tester);
    await tester.pumpWidget(
      await harness(const RoomListScreen(), database: db, prefs: prefs),
    );
    await settle(tester);
  }

  testWidgets('opens as a list, which is what it has always been', (
    tester,
  ) async {
    await addRooms(2);

    await pump(tester);

    expect(find.byType(TrackerCard), findsNWidgets(2));
    expect(find.byType(TrackerTile), findsNothing);
    await unmount(tester);
  });

  testWidgets('the toggle turns the list into a grid', (tester) async {
    await addRooms(2);
    await pump(tester);

    await tester.tap(find.byTooltip('Show as a grid'));
    await tester.pumpAndSettle();

    expect(find.byType(TrackerTile), findsNWidgets(2));
    expect(find.byType(TrackerCard), findsNothing);
    await unmount(tester);
  });

  testWidgets('the shape chosen is remembered', (tester) async {
    await addRooms(1);

    await pump(tester, prefs: {'tracking.view': 'grid'});

    expect(find.byType(TrackerTile), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a page holds a fixed number of entries, with a pager under '
      'it', (tester) async {
    await addRooms(kEntriesPerPage + 3);

    await pump(tester);

    expect(find.byType(TrackerCard), findsNWidgets(kEntriesPerPage));
    // The count above the list is the whole list, not the page.
    expect(find.text('27 ROOMS'), findsOneWidget);
    expect(find.text('1 of 2'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('no pager when everything fits on one page', (tester) async {
    await addRooms(3);

    await pump(tester);

    expect(find.text('1 of 1'), findsNothing);
    expect(find.byTooltip('Next page'), findsNothing);
    await unmount(tester);
  });

  testWidgets('the next page holds the rest', (tester) async {
    await addRooms(kEntriesPerPage + 3);
    await pump(tester);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();

    expect(find.byType(TrackerCard), findsNWidgets(3));
    expect(find.text('2 of 2'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('searching puts the reader back on the first page', (
    tester,
  ) async {
    await addRooms(kEntriesPerPage + 3);
    await pump(tester);
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Room 0');
    await settle(tester);

    expect(find.text('1 of 1'), findsNothing);
    expect(find.byType(TrackerCard), findsNWidgets(10));
    await unmount(tester);
  });

  testWidgets('a room with no artwork shows the photo the owner took', (
    tester,
  ) async {
    final rooms = await addRooms(1);
    await DriftPhotoRepository(db).add(
      ownerId: rooms.single.id,
      bytes: _png,
      mimeType: 'image/png',
    );

    await pump(tester);

    expect(find.byType(Image), findsOneWidget);
    await unmount(tester);
  });
}
