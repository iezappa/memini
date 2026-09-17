import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/backup/presentation/backup_actions.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/features/legal/presentation/legal_links.dart';
import 'package:memini/features/release_notes/presentation/release_notes_providers.dart';
import 'package:memini/features/security/data/pin_service.dart';
import 'package:memini/features/settings/presentation/settings_screen.dart';

import '../../support/harness.dart';

/// ACERCA DE carries what CUMPLIMIENTO.md section 2 asks for: privacy, terms,
/// the developer and how to reach them, and the licences.
void main() {
  late AppDatabase database;
  late List<Uri> opened;

  setUp(() {
    database = memoryDatabase();
    opened = [];
  });
  tearDown(() => database.close());

  Future<void> pumpSettings(WidgetTester tester, {Locale? locale}) async {
    useTallSurface(tester);
    await tester.pumpWidget(
      await harness(
        const SettingsScreen(),
        database: database,
        locale: locale ?? const Locale('en'),
        overrides: [
          pinServiceProvider.overrideWithValue(
            PinService(InMemorySecureStore()),
          ),
          backupFilesProvider.overrideWithValue(FakeBackupFiles()),
          assetBundleProvider.overrideWithValue(DiskAssetBundle()),
          urlOpenerProvider.overrideWithValue((url) async {
            opened.add(url);
            return true;
          }),
        ],
      ),
    );
    await tester.pump();
  }

  testWidgets('lists privacy, terms, contact and licences after the '
      'disclaimer, before the tutorial', (tester) async {
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    final disclaimer = tester
        .getTopLeft(find.textContaining('no account, no server, no sync'))
        .dy;
    expect(top('Privacy policy'), greaterThan(disclaimer));
    expect(top('Terms of use'), greaterThan(top('Privacy policy')));
    expect(top('Developer'), greaterThan(top('Terms of use')));
    expect(
      find.textContaining('Zeke Zappa Developments (iezappa)'),
      findsOneWidget,
    );
    expect(top('Licences'), greaterThan(top('Developer')));
    await tester.pumpAndSettle();
    expect(top('Version 1.1.0'), greaterThan(top('Licences')));
    expect(top('Show the tutorial again'), greaterThan(top('Version 1.1.0')));

    await unmount(tester);
  });

  testWidgets('opens the bundled privacy policy, readable offline', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(find.text('Memini privacy policy'), findsOneWidget);
    expect(find.textContaining('MusicBrainz'), findsWidgets);
    expect(opened, isEmpty, reason: 'the policy must not need a connection');

    await unmount(tester);
  });

  testWidgets('opens the terms in the interface language', (tester) async {
    await pumpSettings(tester, locale: const Locale('es'));

    await tester.tap(find.text('Términos de uso'));
    await tester.pumpAndSettle();

    expect(find.text('Términos de uso de Memini'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('contact opens the issue tracker', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Developer'));
    await tester.pump();

    expect(opened, [Uri.parse('https://github.com/iezappa/memini/issues')]);

    await unmount(tester);
  });

  testWidgets('licences open the licence page', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Licences'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the version row opens the release history', (tester) async {
    await pumpSettings(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Version 1.1.0'));
    await tester.pumpAndSettle();

    expect(find.text('Release notes'), findsOneWidget);
    expect(
      find.textContaining('An optional PIN locks the app'),
      findsOneWidget,
    );

    await unmount(tester);
  });
}
