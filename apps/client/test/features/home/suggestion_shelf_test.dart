import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/tracking/domain/tracked_domain.dart';
import 'package:memini/features/home/domain/mood.dart';
import 'package:memini/features/home/domain/recommendation.dart';
import 'package:memini/features/home/presentation/home_providers.dart';
import 'package:memini/features/home/presentation/widgets/suggestion_shelf.dart';

import '../../support/harness.dart';

/// A source that is configured and answers at once.
class StubSource implements RecommendationSource {
  const StubSource(this.attribution, this.domain);

  @override
  final String attribution;
  @override
  final TrackedDomain domain;

  @override
  bool get isConfigured => true;

  @override
  Future<List<Recommendation>> popular() async => [
    Recommendation(domain: domain, title: 'Something from $attribution'),
  ];

  @override
  Future<List<Recommendation>> forMood(Mood mood) => popular();
}

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      await harness(
        const Scaffold(body: SuggestionShelf()),
        database: db,
        overrides: [
          recommendationSourcesProvider.overrideWithValue(const [
            StubSource('TMDB', TrackedDomain.screen),
            StubSource('RAWG', TrackedDomain.games),
          ]),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it does not explain itself', (tester) async {
    await pump(tester);

    // The sentence that used to sit here said a suggestion is random and is
    // not stored, which the shelf demonstrates by existing.
    expect(find.textContaining('at random'), findsNothing);
    expect(find.textContaining('Nothing is stored'), findsNothing);
    await unmount(tester);
  });

  testWidgets('it still credits whose data this is', (tester) async {
    await pump(tester);

    // Both services require the credit to be visible wherever their data
    // is, so it outlives the sentence it used to be part of.
    expect(find.text('TMDB · RAWG'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('and offers another roll', (tester) async {
    await pump(tester);

    expect(find.text('Something from TMDB'), findsOneWidget);
    expect(find.text('Another'), findsOneWidget);
    await unmount(tester);
  });
}
