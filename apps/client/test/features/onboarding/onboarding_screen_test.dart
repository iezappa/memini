import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/onboarding/presentation/onboarding_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> pumpOnboarding(
    WidgetTester tester, {
    bool tutorialOnly = false,
  }) async {
    await tester.pumpWidget(
      await harness(OnboardingScreen(tutorialOnly: tutorialOnly), database: db),
    );
    await tester.pumpAndSettle();
  }

  /// What the app reads on the next launch to decide whether to show this
  /// flow again — and, for the disclaimer, whether it was ever accepted.
  ({bool tutorial, bool disclaimer}) flags(WidgetTester tester) {
    final settings = ProviderScope.containerOf(
      tester.element(find.byType(OnboardingScreen)),
    ).read(settingsRepositoryProvider);
    return (
      tutorial: settings.tutorialSeen,
      disclaimer: settings.disclaimerAccepted,
    );
  }

  Future<void> tapNext(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(FilledButton, label));
    await tester.pumpAndSettle();
  }

  testWidgets('walks three slides and ends on the disclaimer', (tester) async {
    await pumpOnboarding(tester);

    expect(find.text('Everything you did, in one place'), findsOneWidget);
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

  testWidgets('accepting marks both the tutorial and the disclaimer', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');
    await tapNext(tester, 'I understand');

    expect(flags(tester), (tutorial: true, disclaimer: true));

    await unmount(tester);
  });

  testWidgets('skipping must not accept a disclaimer nobody was shown', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    // Skip is offered from the very first slide, before the disclaimer page
    // has ever been on screen.
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pumpAndSettle();

    expect(
      flags(tester).disclaimer,
      isFalse,
      reason: 'the standard asks for explicit acceptance; skipping is not it',
    );
    // Skip is about the tutorial: it lands on the disclaimer rather than
    // ending the flow, so the text still has to be read and accepted.
    expect(find.text('What Memini is'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'I understand'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('reopened from settings, it shows the slides only', (
    tester,
  ) async {
    await pumpOnboarding(tester, tutorialOnly: true);

    await tapNext(tester, 'Next');
    await tapNext(tester, 'Next');

    expect(find.text('What Memini is'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Close'), findsOneWidget);

    await unmount(tester);
  });
}
