import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/release_notes/presentation/release_notes_providers.dart';
import 'package:memini/features/release_notes/presentation/whats_new_check.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = memoryDatabase());
  tearDown(() => database.close());

  final changelog = jsonEncode({
    'releases': [
      {
        'version': '1.0.0',
        'date': '2026-09-01',
        'highlights': ['The first one'],
      },
      {
        'version': '1.1.0',
        'date': '2026-09-17',
        'highlights': ['The newest one'],
      },
    ],
  });

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    String? lastSeen,
    bool backupNoticeAccepted = true,
  }) async {
    await tester.pumpWidget(
      await harness(
        const WhatsNewCheck(child: Scaffold(body: Text('home'))),
        database: database,
        prefs: {
          'onboarding.backup_notice_accepted': backupNoticeAccepted,
          'releaseNotes.lastSeenVersion': ?lastSeen,
        },
        overrides: [
          assetBundleProvider.overrideWithValue(_FakeBundle(changelog)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.text('home')));
  }

  testWidgets('a first install shows nothing and remembers this version', (
    tester,
  ) async {
    final container = await pump(tester);

    expect(find.byType(AlertDialog), findsNothing);
    expect(container.read(settingsRepositoryProvider).lastSeenVersion, '1.1.0');
  });

  testWidgets('an upgrade shows what changed since, then remembers it', (
    tester,
  ) async {
    final container = await pump(tester, lastSeen: '1.0.0');

    expect(find.text("What's new in 1.1.0"), findsOneWidget);
    expect(find.text('The newest one'), findsOneWidget);
    expect(find.text('The first one'), findsNothing);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(container.read(settingsRepositoryProvider).lastSeenVersion, '1.1.0');
  });

  testWidgets('the same version shows nothing', (tester) async {
    await pump(tester, lastSeen: '1.1.0');

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('waits while the backup notice still has to be answered', (
    tester,
  ) async {
    final container = await pump(
      tester,
      lastSeen: '1.0.0',
      backupNoticeAccepted: false,
    );

    expect(find.text("What's new in 1.1.0"), findsNothing);
    expect(
      container.read(settingsRepositoryProvider).lastSeenVersion,
      '1.0.0',
      reason: 'the notes are owed for the next launch, not skipped',
    );
  });
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._changelog);

  final String _changelog;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(_changelog)));
}
