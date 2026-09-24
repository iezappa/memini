import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/photos/presentation/photo_providers.dart';
import 'package:memini/core/photos/presentation/photo_strip.dart';

import '../../support/harness.dart';

/// One transparent pixel, so `Image.memory` has something real to decode.
final _png = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
    'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, {bool cancelPicker = false}) async {
    await tester.pumpWidget(
      await harness(
        const Scaffold(body: PhotoStrip(ownerId: 'room-1')),
        database: db,
        overrides: [
          photoPickerProvider.overrideWithValue(
            () async =>
                cancelPicker ? null : (bytes: _png, mimeType: 'image/png'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('says so when an entry has no pictures yet', (tester) async {
    await pump(tester);

    expect(find.text('No photos on this one yet.'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('adding one shows it straight away', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Add a photo'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('No photos on this one yet.'), findsNothing);
    await unmount(tester);
  });

  testWidgets('backing out of the picker adds nothing', (tester) async {
    await pump(tester, cancelPicker: true);

    await tester.tap(find.text('Add a photo'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    await unmount(tester);
  });

  testWidgets('removing asks first, and keeps it on a cancel', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Add a photo'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Remove this photo?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('confirming takes it away', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Add a photo'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove photo'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(find.text('No photos on this one yet.'), findsOneWidget);
    await unmount(tester);
  });
}
