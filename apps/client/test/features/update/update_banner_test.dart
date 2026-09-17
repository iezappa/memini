import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/versioning/app_version.dart';
import 'package:memini/features/update/domain/update_service.dart';
import 'package:memini/features/update/presentation/update_banner.dart';
import 'package:memini/features/update/presentation/update_providers.dart';

import '../../support/harness.dart';

class _FakeUpdates implements UpdateService {
  _FakeUpdates(this.info);
  final UpdateInfo? info;
  @override
  Future<UpdateInfo?> check() async => info;
}

void main() {
  late AppDatabase database;
  setUp(() => database = memoryDatabase());
  tearDown(() => database.close());

  UpdateInfo info({bool schemaChange = false, AppVersion? min}) => UpdateInfo(
    latest: const AppVersion(9, 0, 0),
    url: Uri.parse('https://example.test/release'),
    schemaChange: schemaChange,
    minSupportedVersion: min,
  );

  Future<void> pump(
    WidgetTester tester,
    UpdateInfo? update, {
    Map<String, Object> prefs = const {},
    AppVersion current = const AppVersion(1, 0, 0),
  }) async {
    await tester.pumpWidget(
      await harness(
        const Scaffold(body: Column(children: [UpdateBanner()])),
        database: database,
        prefs: prefs,
        overrides: [
          updateServiceProvider.overrideWithValue(_FakeUpdates(update)),
          runningVersionProvider.overrideWith((ref) async => current),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('announces a newer version', (tester) async {
    await pump(tester, info());
    expect(find.text('A new version is available'), findsOneWidget);
    expect(find.text('Version 9.0.0 is available.'), findsOneWidget);
    expect(
      find.textContaining('Export a backup before updating'),
      findsNothing,
    );
  });

  testWidgets('recommends a backup when the schema changes', (tester) async {
    await pump(tester, info(schemaChange: true));
    expect(
      find.textContaining('Export a backup before updating'),
      findsOneWidget,
    );
    expect(find.text('Export'), findsOneWidget);
  });

  testWidgets('says to go step by step below the minimum supported', (
    tester,
  ) async {
    await pump(tester, info(min: const AppVersion(2, 0, 0)));
    expect(find.textContaining('too old to update directly'), findsOneWidget);
  });

  testWidgets('shows nothing without an update', (tester) async {
    await pump(tester, null);
    expect(find.byType(MaterialBanner), findsNothing);
  });

  testWidgets('dismissing hides this version for good', (tester) async {
    await pump(tester, info());
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);

    await pump(tester, info(), prefs: {'update.dismissed_version': '9.0.0'});
    expect(find.byType(MaterialBanner), findsNothing);
  });
}
