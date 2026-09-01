import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/features/shared/support_actions.dart';

import '../../support/harness.dart';

void main() {
  late List<Uri> opened;

  setUp(() => opened = []);

  Future<void> pump(WidgetTester tester, UrlOpener opener) async {
    await tester.pumpWidget(
      await harness(
        Scaffold(body: SupportProjectsCard(opener: opener)),
        database: memoryDatabase(),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows both platforms side by side, never picking one', (
    tester,
  ) async {
    await pump(tester, (url) async => true);

    expect(find.text('Cafecito (Argentina)'), findsOneWidget);
    expect(find.text('Patreon (worldwide)'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('opens the Cafecito link', (tester) async {
    await pump(tester, (url) async {
      opened.add(url);
      return true;
    });

    await tester.tap(find.text('Cafecito (Argentina)'));
    await tester.pump();

    expect(opened, [SupportProjectsCard.cafecito]);

    await unmount(tester);
  });

  testWidgets('opens the Patreon link', (tester) async {
    await pump(tester, (url) async {
      opened.add(url);
      return true;
    });

    await tester.tap(find.text('Patreon (worldwide)'));
    await tester.pump();

    expect(opened, [SupportProjectsCard.patreon]);

    await unmount(tester);
  });

  testWidgets('shows a snack bar when the launcher returns false', (
    tester,
  ) async {
    await pump(tester, (url) async => false);

    await tester.tap(find.text('Cafecito (Argentina)'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Could not open the link.'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('shows a snack bar when the launcher throws', (tester) async {
    await pump(tester, (url) async => throw Exception('no browser'));

    await tester.tap(find.text('Patreon (worldwide)'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Could not open the link.'), findsOneWidget);

    await unmount(tester);
  });
}
