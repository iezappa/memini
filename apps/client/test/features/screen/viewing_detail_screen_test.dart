import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/screen/data/drift_viewing_repository.dart';
import 'package:memini/features/screen/domain/viewing.dart';
import 'package:memini/features/screen/domain/viewing_repository.dart';
import 'package:memini/features/screen/presentation/viewing_detail_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftViewingRepository entries;

  setUp(() {
    db = memoryDatabase();
    entries = DriftViewingRepository(db);
  });
  tearDown(() => db.close());

  Future<Viewing> log() => entries.create(
    ViewingDraft(
      title: 'Severance',
      happenedOn: DateTime(2026, 2, 9),
      kind: ViewingKind.series,
      season: 2,
      review: 'The corridors do the acting.',
    ),
  );

  Future<void> pumpDetail(WidgetTester tester, Viewing entry) => pumpPushed(
    tester,
    ViewingDetailScreen(viewingId: entry.id),
    database: db,
  );

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
  }

  testWidgets('shows what was logged', (tester) async {
    await pumpDetail(tester, await log());

    expect(find.text('Severance'), findsWidgets);
    expect(find.text('The corridors do the acting.'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('warns that the delete cannot be undone', (tester) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);

    expect(
      find.text(
        'This title will be removed from your log. This cannot be undone.',
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
    expect(await entries.list(const ViewingFilter()), hasLength(1));

    await unmount(tester);
  });

  testWidgets('deletes the entry once the delete is confirmed', (tester) async {
    await pumpDetail(tester, await log());

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await entries.list(const ViewingFilter()), isEmpty);

    await unmount(tester);
  });
}
