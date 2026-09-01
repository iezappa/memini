import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/concerts/data/drift_gig_repository.dart';
import 'package:memini/features/concerts/domain/gig.dart';
import 'package:memini/features/concerts/domain/gig_repository.dart';
import 'package:memini/features/concerts/presentation/gig_detail_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftGigRepository entries;

  setUp(() {
    db = memoryDatabase();
    entries = DriftGigRepository(db);
  });
  tearDown(() => db.close());

  Future<Gig> log() => entries.create(
    GigDraft(
      title: 'Divididos',
      happenedOn: DateTime(2026, 4, 18),
      venue: 'Estadio Obras',
      review: 'Loud in the right way.',
    ),
  );

  Future<void> pumpDetail(WidgetTester tester, Gig entry) =>
      pumpPushed(tester, GigDetailScreen(gigId: entry.id), database: db);

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
  }

  testWidgets('shows what was logged', (tester) async {
    await pumpDetail(tester, await log());

    expect(find.text('Divididos'), findsWidgets);
    expect(find.text('Loud in the right way.'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('warns that the delete cannot be undone', (tester) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);

    expect(
      find.text(
        'This gig will be removed from your log. This cannot be undone.',
      ),
      findsOneWidget,
    );

    await unmount(tester);
  });

  testWidgets('leaves the entry alone when the delete is cancelled', (
    tester,
  ) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // There is no server and no undo: a delete that fires on a cancel takes
    // the entry with it for good.
    expect(await entries.list(const GigFilter()), hasLength(1));

    await unmount(tester);
  });

  testWidgets('deletes the entry once the delete is confirmed', (tester) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await entries.list(const GigFilter()), isEmpty);

    await unmount(tester);
  });
}
