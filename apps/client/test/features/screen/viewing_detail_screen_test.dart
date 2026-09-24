import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/features/screen/data/drift_viewing_repository.dart';
import 'package:memini/features/screen/domain/viewing.dart';
import 'package:memini/features/screen/domain/viewing_repository.dart';
import 'package:memini/core/tracking/presentation/tracker_detail.dart';
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

  testWidgets(
    'names the entry it would destroy, and warns it cannot be undone',
    (tester) async {
      await pumpDetail(tester, await log());

      await tapDelete(tester);

      expect(
        find.text('Delete "Severance"? This cannot be undone.'),
        findsOneWidget,
      );

      await unmount(tester);
    },
  );

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

  // A refused delete used to vanish: the screen closed or sat there, and the
  // owner had no way to tell the viewing was still kept.
  testWidgets('says so when the viewing could not be deleted', (tester) async {
    await pumpDetail(tester, await log());
    await refuseDeletes(db, 'viewings');

    await tapDelete(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text(deleteFailedMessage), findsOneWidget);
    expect(find.byType(ViewingDetailScreen), findsOneWidget);
    expect(await entries.list(const ViewingFilter()), hasLength(1));

    await unmount(tester);
  });

  group('the artwork', () {
    testWidgets('opens on the still, blurred, with the cover on it', (
      tester,
    ) async {
      final entry = await entries.create(
        ViewingDraft(
          title: 'Blade Runner 2049',
          happenedOn: DateTime(2026, 2, 9),
          kind: ViewingKind.film,
          posterUrl: 'https://image.tmdb.org/t/p/w500/poster.jpg',
          backdropUrl: 'https://image.tmdb.org/t/p/w1280/backdrop.jpg',
        ),
      );

      await pumpDetail(tester, entry);

      expect(find.byType(ArtHeader), findsOneWidget);
      final header = tester.widget<ArtHeader>(find.byType(ArtHeader));
      expect(header.backdropUrl, contains('backdrop.jpg'));
      expect(header.posterUrl, contains('poster.jpg'));
      // Blurred: text over an unblurred still is unreadable half the time.
      expect(find.byType(ImageFiltered), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('falls back to the cover when there is no still', (
      tester,
    ) async {
      final entry = await entries.create(
        ViewingDraft(
          title: 'Something obscure',
          happenedOn: DateTime(2026, 2, 9),
          kind: ViewingKind.film,
          posterUrl: 'https://image.tmdb.org/t/p/w500/poster.jpg',
        ),
      );

      await pumpDetail(tester, entry);

      final header = tester.widget<ArtHeader>(find.byType(ArtHeader));
      expect(header.backdropUrl, contains('poster.jpg'));

      await unmount(tester);
    });

    testWidgets('stays a plain title block for an entry typed by hand', (
      tester,
    ) async {
      // Four of the five domains never have artwork, and a film written
      // down without a lookup does not either.
      await pumpDetail(tester, await log());

      expect(find.byType(ArtHeader), findsNothing);
      expect(find.text('Severance'), findsWidgets);

      await unmount(tester);
    });
  });
}
