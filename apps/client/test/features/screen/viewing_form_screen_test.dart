import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/screen/data/drift_viewing_repository.dart';
import 'package:memini/features/screen/domain/viewing.dart';
import 'package:memini/features/screen/domain/viewing_repository.dart';
import 'package:memini/features/screen/presentation/viewing_form_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftViewingRepository viewings;

  setUp(() {
    db = memoryDatabase();
    viewings = DriftViewingRepository(db);
  });
  tearDown(() => db.close());

  Future<void> pumpForm(WidgetTester tester, {Viewing? viewing}) =>
      pumpPushed(tester, ViewingFormScreen(viewing: viewing), database: db);

  Future<void> chooseKind(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('will not save a viewing with no title', (tester) async {
    await pumpForm(tester);

    await tapSave(tester);

    expect(find.text('It needs a title'), findsOneWidget);
    expect(await viewings.list(const ViewingFilter()), isEmpty);

    await unmount(tester);
  });

  testWidgets('asks for a season only once the kind is a series', (
    tester,
  ) async {
    await pumpForm(tester);

    // Films open the form, and a film has no season.
    expect(fieldLabelled('Season'), findsNothing);

    await chooseKind(tester, 'Series');
    expect(fieldLabelled('Season'), findsOneWidget);

    await chooseKind(tester, 'Miniseries');
    expect(fieldLabelled('Season'), findsOneWidget);

    await chooseKind(tester, 'Documentary');
    expect(fieldLabelled('Season'), findsNothing);

    await unmount(tester);
  });

  testWidgets('drops a season typed before switching back to a film', (
    tester,
  ) async {
    await pumpForm(tester);

    await fillField(tester, 'Title', 'Severance');
    await chooseKind(tester, 'Series');
    await fillField(tester, 'Season', '2');

    // Changing your mind about the kind has to take the season with it, or a
    // film keeps a stale number nobody can see or correct.
    await chooseKind(tester, 'Film');
    await tapSave(tester);

    final saved = (await viewings.list(const ViewingFilter())).single;
    expect(saved.kind, ViewingKind.film);
    expect(saved.season, isNull);

    await unmount(tester);
  });

  testWidgets('records the kind, the year and the people behind it', (
    tester,
  ) async {
    await pumpForm(tester);

    await fillField(tester, 'Title', 'Severance');
    await chooseKind(tester, 'Series');
    await fillField(tester, 'Season', '2');
    await fillField(tester, 'Release year', '2022');
    await fillField(tester, 'Director', 'Ben Stiller');
    await fillField(tester, 'Cast', 'Adam Scott, Britt Lower');
    await tapSave(tester);

    final saved = (await viewings.list(const ViewingFilter())).single;
    expect(saved.kind, ViewingKind.series);
    expect(saved.season, 2);
    expect(saved.releaseYear, 2022);
    expect(saved.director, 'Ben Stiller');
    expect(saved.cast, 'Adam Scott, Britt Lower');

    await unmount(tester);
  });

  testWidgets('opens on the viewing being edited and updates it in place', (
    tester,
  ) async {
    final original = await viewings.create(
      ViewingDraft(
        title: 'Severance',
        happenedOn: DateTime(2026, 2, 9),
        kind: ViewingKind.series,
        season: 1,
      ),
    );

    await pumpForm(tester, viewing: original);

    expect(fieldLabelled('Season'), findsOneWidget);

    await fillField(tester, 'Season', '2');
    await tapSave(tester);

    final all = await viewings.list(const ViewingFilter());
    expect(all, hasLength(1), reason: 'editing must update, never insert');
    expect(all.single.id, original.id);
    expect(all.single.season, 2);

    await unmount(tester);
  });
}
