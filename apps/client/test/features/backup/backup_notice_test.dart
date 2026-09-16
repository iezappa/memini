import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/features/backup/presentation/backup_notice.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool accepted}) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      await harness(
        const BackupNoticeCheck(child: Scaffold(body: Text('the app'))),
        database: db,
        prefs: {
          'onboarding.tutorial_seen': true,
          'onboarding.disclaimer_accepted': true,
          'onboarding.backup_notice_accepted': accepted,
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  const title = 'Your data lives only on this device';

  group('someone onboarded before the backup notice existed', () {
    testWidgets('is shown it once', (tester) async {
      await pump(tester, accepted: false);

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('cannot wave it away without accepting it', (tester) async {
      await pump(tester, accepted: false);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('does not see it again once accepted', (tester) async {
      await pump(tester, accepted: false);

      await tester.tap(find.text("Got it, I'll back up"));
      await tester.pumpAndSettle();

      expect(find.text(title), findsNothing);
      final container = ProviderScope.containerOf(
        tester.element(find.text('the app')),
      );
      expect(
        container.read(settingsRepositoryProvider).backupNoticeAccepted,
        isTrue,
      );
    });
  });

  testWidgets('someone who already accepted it goes straight in', (
    tester,
  ) async {
    await pump(tester, accepted: true);

    expect(find.text(title), findsNothing);
    expect(find.text('the app'), findsOneWidget);
  });
}
