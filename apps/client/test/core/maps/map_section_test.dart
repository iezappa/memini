import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/maps/presentation/map_preview.dart';
import 'package:memini/core/maps/presentation/map_section.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, String? link) async {
    await tester.pumpWidget(
      await harness(
        Scaffold(body: MapSection(mapsUrl: link)),
        database: db,
      ),
    );
    await tester.pump();
  }

  testWidgets('a link with a position draws the map', (tester) async {
    await pump(tester, 'https://www.openstreetmap.org/#map=19/-34.58/-58.42');

    expect(find.byType(MapPreview), findsOneWidget);
    expect(find.text('Open in maps'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the map credits the people who surveyed it', (tester) async {
    await pump(tester, 'geo:-34.5883,-58.4262');

    expect(find.text('© OpenStreetMap'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a shortened link still opens, and says why it cannot be '
      'drawn', (tester) async {
    await pump(tester, 'https://maps.app.goo.gl/aBcDeF12');

    expect(find.byType(MapPreview), findsNothing);
    expect(find.text('Open in maps'), findsOneWidget);
    expect(find.textContaining('no position in it'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('no link at all shows nothing, not an empty box', (
    tester,
  ) async {
    await pump(tester, null);

    expect(find.text('Open in maps'), findsNothing);
    expect(find.textContaining('Where it is'), findsNothing);
    await unmount(tester);
  });

  testWidgets('it reads in Spanish too', (tester) async {
    await tester.pumpWidget(
      await harness(
        const Scaffold(body: MapSection(mapsUrl: 'geo:-34.5883,-58.4262')),
        database: db,
        locale: const Locale('es'),
      ),
    );
    await tester.pump();

    expect(find.text('Abrir en el mapa'), findsOneWidget);
    await unmount(tester);
  });
}
