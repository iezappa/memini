import '../domain/enrichment.dart';

/// Finds the artwork for an entry that was saved before the app kept any.
///
/// Entries written between the lookup existing and the artwork being read
/// from it carry an id from the source and no picture. They were already
/// filled in from that service once, so asking it for the cover of the same
/// title tells it nothing it was not told the day the entry was created.
///
/// By title and then matched on the id, rather than by the id directly: the
/// stored id does not say whether it is a film or a series, and TMDB needs
/// to know which before it will answer. One search covers both.
///
/// Returns null when the title no longer matches anything, which is not an
/// error worth reporting: the entry simply keeps the look it has had all
/// along.
Future<EnrichmentSuggestion?> findArtwork({
  required EnrichmentSource source,
  required String title,
  required String externalId,
}) async {
  if (!source.isConfigured) return null;

  try {
    for (final match in await source.search(title)) {
      if (match.externalId == externalId) return match;
    }
  } on EnrichmentException {
    // Offline, throttled, key withdrawn: all the same answer here, which
    // is that the entry keeps showing what it already shows.
    return null;
  }

  return null;
}
