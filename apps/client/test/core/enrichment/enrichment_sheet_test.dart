import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/enrichment/domain/enrichment.dart';
import 'package:memini/core/enrichment/presentation/enrichment_sheet.dart';

import '../../support/harness.dart';

/// A source whose search is instant and whose detail call is not, so the
/// wait between picking and closing is something a test can stand inside.
class SlowSource implements EnrichmentSource {
  SlowSource({this.detailDelay = Duration.zero});

  final Duration detailDelay;
  final List<String> detailsAsked = [];

  @override
  String get attribution => 'Test';

  @override
  String get attributionUrl => 'https://example.test/';

  @override
  bool get isConfigured => true;

  @override
  Future<List<EnrichmentSuggestion>> search(String query) async => const [
    EnrichmentSuggestion(externalId: '1', title: 'Outer Wilds'),
    EnrichmentSuggestion(externalId: '2', title: 'Outer Wilds: Echoes'),
  ];

  @override
  Future<EnrichmentSuggestion> details(EnrichmentSuggestion picked) async {
    detailsAsked.add(picked.externalId);
    if (detailDelay > Duration.zero) await Future<void>.delayed(detailDelay);

    return picked.withDescription('You are the newest recruit.');
  }
}

void main() {
  late AppDatabase db;
  late SlowSource source;
  EnrichmentSuggestion? picked;

  setUp(() {
    db = memoryDatabase();
    picked = null;
  });
  tearDown(() => db.close());

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      await harness(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                picked = await showEnrichmentSheet(
                  context: context,
                  source: source,
                  initialQuery: 'outer wilds',
                );
              },
              child: const Text('look up'),
            ),
          ),
        ),
        database: db,
      ),
    );
    await tester.tap(find.text('look up'));
    await tester.pumpAndSettle();
  }

  testWidgets('the picked candidate comes back with its description', (
    tester,
  ) async {
    source = SlowSource();
    await open(tester);

    await tester.tap(find.text('Outer Wilds: Echoes'));
    await tester.pumpAndSettle();

    expect(source.detailsAsked, ['2'], reason: 'only the one that was picked');
    expect(picked!.description, 'You are the newest recruit.');
    await unmount(tester);
  });

  testWidgets('the row being fetched says so, and the others stop taking '
      'taps', (tester) async {
    source = SlowSource(detailDelay: const Duration(milliseconds: 300));
    await open(tester);

    await tester.tap(find.text('Outer Wilds'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // A second tap while the first is in flight must not ask twice.
    await tester.tap(find.text('Outer Wilds: Echoes'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(source.detailsAsked, ['1']);
    expect(picked!.externalId, '1');
    await unmount(tester);
  });
}
