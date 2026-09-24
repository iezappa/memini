import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/onboarding/presentation/tutorial_dialog.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  /// Opens the tour the way the app does: over something, not instead of it.
  Future<void> openTutorial(
    WidgetTester tester, {
    bool onboarding = true,
  }) async {
    late BuildContext host;
    await tester.pumpWidget(
      await harness(
        Scaffold(
          body: Builder(
            builder: (context) {
              host = context;
              return const SizedBox.expand();
            },
          ),
        ),
        database: db,
      ),
    );
    await tester.pumpAndSettle();

    // Not awaited: it only completes once the dialog is closed.
    unawaited(showTutorial(host, onboarding: onboarding));
    await tester.pumpAndSettle();
  }

  /// What the app reads on the next launch to decide whether to show this
  /// again — and, for the disclaimer, whether it was ever accepted.
  ({bool tutorial, bool disclaimer, bool backupNotice}) flags(
    WidgetTester tester,
  ) {
    final settings = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(settingsRepositoryProvider);
    return (
      tutorial: settings.tutorialSeen,
      disclaimer: settings.disclaimerAccepted,
      backupNotice: settings.backupNoticeAccepted,
    );
  }

  Future<void> tapNext(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(FilledButton, label));
    await tester.pumpAndSettle();
  }

  testWidgets('is a dialog over the app, not a page instead of it', (
    tester,
  ) async {
    // The whole point of the change: at first launch the app used to hide
    // itself behind a full-screen brochure.
    await openTutorial(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Everything you did, in one place'), findsOneWidget);
    expect(find.text('1 of 4'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('walks three slides and ends on the disclaimer', (tester) async {
    await openTutorial(tester);

    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');

    expect(find.text('What Memini is'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'I understand'),
      findsOneWidget,
      reason: 'the flow ends by accepting, not by continuing',
    );

    await unmount(tester);
  });

  testWidgets('accepting marks the tutorial, the disclaimer and the backup '
      'notice', (tester) async {
    await openTutorial(tester);

    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');
    // The disclaimer is a paragraph, so the checkbox under it starts below
    // the fold of the dialog's own scroll view.
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tapNext(tester, 'I understand');

    expect(flags(tester), (
      tutorial: true,
      disclaimer: true,
      backupNotice: true,
    ));
    expect(find.byType(AlertDialog), findsNothing, reason: 'and it closes');

    await unmount(tester);
  });

  testWidgets('will not finish until the notice is acknowledged', (
    tester,
  ) async {
    await openTutorial(tester);
    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');

    expect(find.text('Your data lives only on this device'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'I understand'),
          )
          .onPressed,
      isNull,
    );

    await unmount(tester);
  });

  testWidgets('a first run offers no way around the disclaimer', (
    tester,
  ) async {
    // Skip used to jump to the last page, which was an odd thing to offer:
    // the page it lands on is the one that has to be read. There is no Skip
    // on a first run now, and the barrier does not dismiss it either.
    await openTutorial(tester);

    expect(find.widgetWithText(TextButton, 'Skip'), findsNothing);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(flags(tester).disclaimer, isFalse);

    await unmount(tester);
  });

  testWidgets('reopened from settings, it shows the slides only', (
    tester,
  ) async {
    await openTutorial(tester, onboarding: false);

    expect(find.text('1 of 3'), findsOneWidget);
    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');

    expect(find.text('What Memini is'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Close'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('reopened from settings, it accepts nothing', (tester) async {
    // Reading the tour again is not agreeing to anything again, and it must
    // not stamp the flags on a device where they are somehow unset.
    await openTutorial(tester, onboarding: false);
    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');
    await tapNext(tester, 'Close');

    expect(flags(tester), (
      tutorial: false,
      disclaimer: false,
      backupNotice: false,
    ));

    await unmount(tester);
  });
}
