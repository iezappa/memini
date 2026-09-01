import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/franchises/data/drift_franchise_repository.dart';
import 'package:memini/features/franchises/domain/franchise.dart';
import 'package:memini/features/rooms/data/drift_room_repository.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/rooms/presentation/room_list_screen.dart';

import '../../support/harness.dart';

/// The list starts on a CircularProgressIndicator, whose animation never
/// stops — pumpAndSettle would wait for it forever. Pumping a bounded number
/// of frames lets the stream deliver and the spinner disappear.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      await harness(const RoomListScreen(), database: db),
    );
    await settle(tester);
  }

  testWidgets('shows the empty state when nothing is logged', (tester) async {
    await pump(tester);

    expect(find.text('Nothing logged yet'), findsOneWidget);
    expect(find.text('Add room'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('lists a logged room with its franchise, date and score', (
    tester,
  ) async {
    final franchise = await DriftFranchiseRepository(db)
        .create(const FranchiseDraft(name: 'Enigma'));
    await DriftRoomRepository(db).create(
      RoomDraft(
        title: 'The Vault',
        franchiseId: franchise.id,
        rating: 9.5,
        happenedOn: DateTime(2026, 3, 14),
        escaped: true,
        timeLeftMinutes: 4,
      ),
    );

    await pump(tester);

    expect(find.text('The Vault'), findsOneWidget);
    expect(find.text('Enigma · Mar 14, 2026'), findsOneWidget);
    expect(find.text('9.5'), findsOneWidget);
    expect(find.text('Escaped · 4 min left'), findsOneWidget);
    expect(find.text('1 ROOM'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('searching narrows the list and can be cleared', (tester) async {
    final rooms = DriftRoomRepository(db);
    await rooms.create(
      RoomDraft(
        title: 'The Vault',
        happenedOn: DateTime(2026, 1, 1),
        escaped: true,
      ),
    );
    await rooms.create(
      RoomDraft(
        title: 'Cabin in the woods',
        happenedOn: DateTime(2026, 1, 2),
        escaped: false,
      ),
    );

    await pump(tester);
    expect(find.text('2 ROOMS'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cabin');
    await settle(tester);

    expect(find.text('Cabin in the woods'), findsOneWidget);
    expect(find.text('The Vault'), findsNothing);

    // The "clear filters" chip also carries a close icon once a query is
    // active, so target the one inside the search field.
    await tester.tap(
      find.descendant(
        of: find.byType(TextField),
        matching: find.byIcon(Icons.close),
      ),
    );
    await settle(tester);

    expect(find.text('2 ROOMS'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the outcome filter shows the empty-filter message', (
    tester,
  ) async {
    await DriftRoomRepository(db).create(
      RoomDraft(
        title: 'The Vault',
        happenedOn: DateTime(2026, 1, 1),
        escaped: true,
      ),
    );

    await pump(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Not escaped'));
    await settle(tester);

    expect(find.text('No room matches these filters.'), findsOneWidget);
    expect(find.text('Clear filters'), findsWidgets);

    await unmount(tester);
  });

  testWidgets('renders in Spanish when the locale is es', (tester) async {
    await tester.pumpWidget(
      await harness(
        const RoomListScreen(),
        database: db,
        locale: const Locale('es'),
      ),
    );
    await settle(tester);

    expect(find.text('Todavía no registraste nada'), findsOneWidget);
    expect(find.text('Agregar sala'), findsOneWidget);

    await unmount(tester);
  });
}
