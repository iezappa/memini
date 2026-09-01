import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/rooms/domain/room_repository.dart';
import 'package:memini/features/rooms/presentation/room_form_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftRoomRepository rooms;
  late DriftFranchiseRepository franchises;

  setUp(() {
    db = memoryDatabase();
    rooms = DriftRoomRepository(db);
    franchises = DriftFranchiseRepository(db);
  });
  tearDown(() => db.close());

  /// The form is pushed rather than mounted as `home`, so that saving has a
  /// route to pop the way it does in the app.
  Future<void> pumpForm(WidgetTester tester, {Room? room}) async {
    useTallSurface(tester);
    await tester.pumpWidget(
      await harness(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => RoomFormScreen(room: room),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        database: db,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// Fields are labelled, not keyed, so the label is how a user finds them.
  Finder fieldLabelled(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(TextField));

  Future<void> fill(WidgetTester tester, String label, String value) async {
    await tester.enterText(fieldLabelled(label).first, value);
    await tester.pump();
  }

  /// The app bar and the bottom of the form both offer Save; either does.
  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('will not save a room with no name', (tester) async {
    await pumpForm(tester);

    await save(tester);

    expect(find.text('A room needs a name.'), findsOneWidget);
    expect(await rooms.list(const RoomFilter()), isEmpty);

    await unmount(tester);
  });

  testWidgets('saves the room the way it was typed', (tester) async {
    await pumpForm(tester);

    await fill(tester, 'Name', 'The Vault');
    await fill(tester, 'Description', 'A bank heist, badly lit.');
    await fill(tester, 'Review', 'Worth it for the last puzzle alone.');
    await save(tester);

    final saved = (await rooms.list(const RoomFilter())).single;
    expect(saved.title, 'The Vault');
    expect(saved.description, 'A bank heist, badly lit.');
    expect(saved.review, 'Worth it for the last puzzle alone.');

    await unmount(tester);
  });

  testWidgets('trims the name before storing it', (tester) async {
    await pumpForm(tester);

    await fillField(tester, 'Name', '  The Vault  ');
    await tapSave(tester);

    // Stray spaces are invisible on screen but not to the sort: titleAsc
    // orders on the raw string, so a leading space jumps the room to the top
    // of the list for no reason the owner can see.
    expect((await rooms.list(const RoomFilter())).single.title, 'The Vault');

    await unmount(tester);
  });

  testWidgets('leaves an untouched optional field empty, not blank', (
    tester,
  ) async {
    await pumpForm(tester);

    await fill(tester, 'Name', 'The Vault');
    await save(tester);

    final saved = (await rooms.list(const RoomFilter())).single;
    expect(saved.description, isNull);
    expect(saved.review, isNull);
    // An untouched slider must not read as a score of zero: "unrated" and
    // "rated zero" are different things everywhere else in the app.
    expect(saved.rating, isNull);

    await unmount(tester);
  });

  testWidgets('hides the time left once the room is marked as not escaped', (
    tester,
  ) async {
    await pumpForm(tester);

    expect(fieldLabelled('Time left (minutes)'), findsOneWidget);

    await tester.tap(find.text('Did not escape'));
    await tester.pumpAndSettle();

    expect(fieldLabelled('Time left (minutes)'), findsNothing);

    await unmount(tester);
  });

  testWidgets('drops the minutes left when the room ends up not escaped', (
    tester,
  ) async {
    await pumpForm(tester);

    await fill(tester, 'Name', 'The Vault');
    await fill(tester, 'Time left (minutes)', '4');

    // Changing your mind about the outcome has to take the minutes with it —
    // time left on a room nobody escaped is a contradiction.
    await tester.tap(find.text('Did not escape'));
    await tester.pumpAndSettle();
    await save(tester);

    final saved = (await rooms.list(const RoomFilter())).single;
    expect(saved.escaped, isFalse);
    expect(saved.timeLeftMinutes, isNull);

    await unmount(tester);
  });

  testWidgets('reuses a franchise that already exists, whatever the casing', (
    tester,
  ) async {
    final existing = await franchises.create(
      const FranchiseDraft(name: 'Enigma Rooms'),
    );

    await pumpForm(tester);
    await fill(tester, 'Name', 'The Vault');
    await fill(tester, 'Franchise', 'enigma rooms');
    await save(tester);

    expect(
      await franchises.listAll(),
      hasLength(1),
      reason: 'a difference in casing must not fork a second franchise',
    );
    final saved = (await rooms.list(const RoomFilter())).single;
    expect(saved.franchiseId, existing.id);

    await unmount(tester);
  });

  testWidgets('opens on the room being edited and updates it in place', (
    tester,
  ) async {
    final original = await rooms.create(
      RoomDraft(
        title: 'The Vault',
        happenedOn: DateTime(2026, 3, 14),
        escaped: true,
        review: 'First pass.',
      ),
    );

    await pumpForm(tester, room: original);

    expect(find.text('Edit room'), findsOneWidget);
    expect(find.text('The Vault'), findsWidgets);

    await fill(tester, 'Review', 'Second pass, still good.');
    await save(tester);

    final all = await rooms.list(const RoomFilter());
    expect(all, hasLength(1), reason: 'editing must update, never insert');
    expect(all.single.id, original.id);
    expect(all.single.review, 'Second pass, still good.');

    await unmount(tester);
  });
}
