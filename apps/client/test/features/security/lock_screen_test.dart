import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/app/providers.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/security/data/pin_service.dart';
import 'package:memini/features/security/presentation/lock_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late PinService pins;

  setUp(() {
    db = memoryDatabase();
    pins = PinService(InMemorySecureStore());
  });
  tearDown(() => db.close());

  Future<void> pumpLock(WidgetTester tester) async {
    await tester.pumpWidget(
      await harness(
        const LockScreen(),
        database: db,
        overrides: [pinServiceProvider.overrideWithValue(pins)],
      ),
    );
    await tester.pump();
  }

  /// The gate is the provider, not the pixels: the router only builds the app
  /// once this flips.
  bool isUnlocked(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(LockScreen)))
          .read(unlockedProvider);

  Future<void> enterPin(WidgetTester tester, String pin) async {
    await tester.enterText(find.byType(TextField), pin);
    await tester.pump();
  }

  Future<void> tapUnlock(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pumpAndSettle();
  }

  testWidgets('starts locked', (tester) async {
    await pins.setPin('2468');
    await pumpLock(tester);

    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(isUnlocked(tester), isFalse);

    await unmount(tester);
  });

  testWidgets('unlocks on the right PIN', (tester) async {
    await pins.setPin('2468');
    await pumpLock(tester);

    await enterPin(tester, '2468');
    await tapUnlock(tester);

    expect(isUnlocked(tester), isTrue);

    await unmount(tester);
  });

  testWidgets('refuses a wrong PIN and says so', (tester) async {
    await pins.setPin('2468');
    await pumpLock(tester);

    await enterPin(tester, '1111');
    await tapUnlock(tester);

    expect(find.text('Wrong PIN.'), findsOneWidget);
    expect(
      isUnlocked(tester),
      isFalse,
      reason: 'a wrong PIN must never open the app',
    );

    await unmount(tester);
  });

  testWidgets('clears the field after a wrong attempt', (tester) async {
    await pins.setPin('2468');
    await pumpLock(tester);

    await enterPin(tester, '1111');
    await tapUnlock(tester);

    // Leaving the digits on screen hands the next attempt, and anyone
    // watching, a free look at what was already tried.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );

    await unmount(tester);
  });

  testWidgets('hides the digits while they are typed', (tester) async {
    await pins.setPin('2468');
    await pumpLock(tester);

    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );

    await unmount(tester);
  });

  testWidgets('takes digits only', (tester) async {
    await pins.setPin('2468');
    await pumpLock(tester);

    await enterPin(tester, '24a6b8');

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '2468',
      reason: 'letters must never reach the hash',
    );

    await unmount(tester);
  });

  testWidgets('unlocks from the keyboard as well as the button', (
    tester,
  ) async {
    await pins.setPin('2468');
    await pumpLock(tester);

    await enterPin(tester, '2468');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(isUnlocked(tester), isTrue);

    await unmount(tester);
  });

  testWidgets('stays shut when no PIN was ever set', (tester) async {
    await pumpLock(tester);

    await enterPin(tester, '2468');
    await tapUnlock(tester);

    // No stored hash must read as "nothing matches", never as "anything does".
    expect(isUnlocked(tester), isFalse);

    await unmount(tester);
  });
}
