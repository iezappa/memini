import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/shared/settings_button.dart';

import '../support/harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> pumpAt(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      await harness(
        Scaffold(appBar: AppBar(actions: const [SettingsButton()])),
        database: db,
      ),
    );
    await tester.pump();
  }

  testWidgets('on a phone it is the gear in the corner', (tester) async {
    await pumpAt(tester, 500);

    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('where the rail is showing it stands down', (tester) async {
    await pumpAt(tester, SettingsButton.railFrom);

    // The rail has a gear of its own at its foot. Two gears on one screen
    // is not twice as easy to find; it is a question about whether they do
    // the same thing.
    expect(find.byIcon(Icons.settings_outlined), findsNothing);
    await unmount(tester);
  });
}
