import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/tracking/domain/tracked_domain.dart';
import '../domain/enrichment.dart';
import 'musicbrainz_source.dart';
import 'rawg_source.dart';
import 'tmdb_source.dart';

/// Identifies Memini to MusicBrainz, which throttles anonymous callers hard.
const kMusicBrainzUserAgent = 'Memini/1.0 (https://github.com/zyreth/memini)';

final tmdbSourceProvider = Provider<EnrichmentSource>(
  (ref) => TmdbSource(apiKey: ref.watch(tmdbApiKeyProvider)),
);

final rawgSourceProvider = Provider<EnrichmentSource>(
  (ref) => RawgSource(apiKey: ref.watch(rawgApiKeyProvider)),
);

final musicBrainzSourceProvider = Provider<EnrichmentSource>(
  (ref) => const MusicBrainzSource(userAgent: kMusicBrainzUserAgent),
);

/// The source for a domain, or null where no free API covers it.
///
/// Dining is deliberately absent: no free places API returns photos and
/// reviews, and a paid one would break the app's local-first, no-account
/// promise for the least valuable of the five.
EnrichmentSource? enrichmentSourceFor(WidgetRef ref, TrackedDomain domain) {
  return switch (domain) {
    TrackedDomain.screen => ref.watch(tmdbSourceProvider),
    TrackedDomain.games => ref.watch(rawgSourceProvider),
    TrackedDomain.concerts => ref.watch(musicBrainzSourceProvider),
    TrackedDomain.rooms || TrackedDomain.dining => null,
  };
}
