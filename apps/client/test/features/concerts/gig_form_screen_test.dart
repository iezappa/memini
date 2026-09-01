import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/concerts/data/drift_gig_repository.dart';
import 'package:memini/features/concerts/domain/gig.dart';
import 'package:memini/features/concerts/domain/gig_repository.dart';
import 'package:memini/features/concerts/presentation/gig_form_screen.dart';

import '../../support/harness.dart';

void main() {
  late AppDatabase db;
  late DriftGigRepository gigs;

  setUp(() {
    db = memoryDatabase();
    gigs = DriftGigRepository(db);
  });
  tearDown(() => db.close());

  Future<void> pumpForm(WidgetTester tester, {Gig? gig}) =>
      pumpPushed(tester, GigFormScreen(gig: gig), database: db);

  testWidgets('will not save a gig with no band', (tester) async {
    await pumpForm(tester);

    await tapSave(tester);

    expect(find.text('The band needs a name'), findsOneWidget);
    expect(await gigs.list(const GigFilter()), isEmpty);

    await unmount(tester);
  });

  testWidgets('records the venue, the city and who came along', (tester) async {
    await pumpForm(tester);

    await fillField(tester, 'Band', 'Divididos');
    await fillField(tester, 'Venue', 'Estadio Obras');
    await fillField(tester, 'City', 'Buenos Aires');
    await fillField(tester, 'With', 'Ana');
    await tapSave(tester);

    final saved = (await gigs.list(const GigFilter())).single;
    expect(saved.title, 'Divididos');
    expect(saved.venue, 'Estadio Obras');
    expect(saved.city, 'Buenos Aires');
    expect(saved.company, 'Ana');

    await unmount(tester);
  });

  testWidgets('keeps the setlist and support acts exactly as typed', (
    tester,
  ) async {
    await pumpForm(tester);

    await fillField(tester, 'Band', 'Divididos');
    await fillField(tester, 'Support acts', 'Las Pelotas, Massacre');
    await fillField(tester, 'Setlist', 'Spaghetti del rock\nEl 38');
    await tapSave(tester);

    final saved = (await gigs.list(const GigFilter())).single;
    // Free text on purpose: the app never parses these into lists, so a
    // comma or a line break has to survive the round trip untouched.
    expect(saved.supportActs, 'Las Pelotas, Massacre');
    expect(saved.setlist, 'Spaghetti del rock\nEl 38');

    await unmount(tester);
  });

  testWidgets('leaves the fields nobody filled in empty, not blank', (
    tester,
  ) async {
    await pumpForm(tester);

    await fillField(tester, 'Band', 'Divididos');
    await tapSave(tester);

    final saved = (await gigs.list(const GigFilter())).single;
    expect(saved.venue, isNull);
    expect(saved.city, isNull);
    expect(saved.setlist, isNull);
    expect(saved.rating, isNull);

    await unmount(tester);
  });

  testWidgets('opens on the gig being edited and updates it in place', (
    tester,
  ) async {
    final original = await gigs.create(
      GigDraft(
        title: 'Divididos',
        happenedOn: DateTime(2026, 4, 18),
        venue: 'Estadio Obras',
      ),
    );

    await pumpForm(tester, gig: original);

    await fillField(tester, 'Venue', 'Luna Park');
    await tapSave(tester);

    final all = await gigs.list(const GigFilter());
    expect(all, hasLength(1), reason: 'editing must update, never insert');
    expect(all.single.id, original.id);
    expect(all.single.venue, 'Luna Park');

    await unmount(tester);
  });
}
