import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/security/data/pin_service.dart';
import 'package:memini/features/settings/presentation/settings_screen.dart';
import 'package:memini/features/shared/widgets.dart';

import '../../support/harness.dart';

class _InMemorySecureStore implements SecureStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

/// The settings screen follows the shared layout every Zyreth app uses: a
/// single flat column of sections, each opened by an uppercase [SectionLabel],
/// with the controls sitting directly on the page.
///
/// These are structure tests on purpose. The standard is only a standard if
/// something fails when a screen drifts away from it.
void main() {
  late AppDatabase database;

  setUp(() => database = memoryDatabase());
  tearDown(() => database.close());

  Future<void> pumpSettings(WidgetTester tester) async {
    // Tall enough that the whole page is built in one pass: a ListView only
    // builds what fits, and these are assertions about the page as a whole.
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      await harness(
        const SettingsScreen(),
        database: database,
        overrides: [
          pinServiceProvider.overrideWithValue(
            PinService(_InMemorySecureStore()),
          ),
        ],
      ),
    );
    await tester.pump();
  }

  testWidgets('opens every section with an uppercase label, in the standard '
      'order', (tester) async {
    await pumpSettings(tester);

    final labels = tester
        .widgetList<SectionLabel>(find.byType(SectionLabel))
        .map((label) => label.text.toUpperCase())
        .toList();

    expect(labels, [
      'APPEARANCE',
      'PROFILE',
      'LANGUAGE',
      'SECURITY',
      'LOOKUPS',
      'YOUR DATA',
      'SUPPORT',
      'ABOUT',
    ]);

    await unmount(tester);
  });

  testWidgets('lays the sections out flat — no card boxes the settings in', (
    tester,
  ) async {
    await pumpSettings(tester);

    // The support block is the one deliberate card; every other control sits
    // straight on the page, which is what separates this layout from a
    // grouped-card one.
    for (final label in [
      'PIN lock',
      'Your name',
      'TMDB key (films and series)',
    ]) {
      expect(
        find.ancestor(
          of: find.widgetWithText(ListTile, label),
          matching: find.byType(Card),
        ),
        findsNothing,
        reason: '"$label" must not be wrapped in a Card',
      );
    }

    await unmount(tester);
  });

  testWidgets('sits every tile flush against the page gutter', (tester) async {
    await pumpSettings(tester);

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
    expect(tiles, isNotEmpty);
    for (final tile in tiles) {
      expect(
        tile.contentPadding,
        EdgeInsets.zero,
        reason: 'a flat layout indents nothing: the page gutter is the margin',
      );
    }

    await unmount(tester);
  });

  testWidgets('shows the disclaimer text itself, not a tile that hides it', (
    tester,
  ) async {
    await pumpSettings(tester);

    final body = find.textContaining('no account, no server, no sync');
    expect(body, findsOneWidget);
    expect(
      find.ancestor(of: body, matching: find.byType(ListTile)),
      findsNothing,
      reason: 'the disclaimer must be readable without tapping anything',
    );

    await unmount(tester);
  });
}
