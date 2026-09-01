/// One candidate returned by a lookup, already normalised to the fields a
/// form can fill in.
///
/// Deliberately flat and optional: every source knows a different subset, and
/// a field the source did not return must stay null rather than become an
/// empty string that would overwrite what the owner typed.
class EnrichmentSuggestion {
  const EnrichmentSuggestion({
    required this.externalId,
    required this.title,
    this.description,
    this.imageUrl,
    this.releaseYear,
    this.director,
    this.cast,
    this.platforms,
    this.origin,
  });

  /// The source's own id, cached so a later lookup can skip the search.
  final String externalId;
  final String title;
  final String? description;

  /// Remote cover art. Downloaded only when the owner accepts the suggestion,
  /// so browsing candidates costs one request, not one per row.
  final String? imageUrl;
  final int? releaseYear;
  final String? director;

  /// Principal cast, comma separated.
  final String? cast;

  /// Platforms the game runs on, comma separated.
  final String? platforms;

  /// Where an act is from — the only extra a music lookup reliably knows.
  final String? origin;

  /// A one-line hint under the title in the picker, so two films with the
  /// same name are still tellable apart.
  String get subtitle =>
      [?releaseYear?.toString(), ?director, ?origin, ?platforms].join(' · ');
}

/// Why a lookup produced nothing. The form treats all of these the same way —
/// it stays editable by hand — but the message differs.
enum EnrichmentFailure {
  /// The device has no connection, or the host could not be reached.
  offline,

  /// No API key is configured for this source.
  missingKey,

  /// The source answered, but with an error or something unparseable.
  failed,
}

/// Raised by a source when a lookup cannot be completed.
class EnrichmentException implements Exception {
  const EnrichmentException(this.reason);

  final EnrichmentFailure reason;

  @override
  String toString() => 'EnrichmentException: ${reason.name}';
}

/// A place to look up details for one domain.
///
/// Enrichment is always OPTIONAL: every form works fully without it, and a
/// source that is unreachable must never block saving an entry.
abstract interface class EnrichmentSource {
  /// The name shown in the attribution line. Both TMDB and RAWG require the
  /// credit to be visible wherever their data is.
  String get attribution;

  /// The page the attribution links to. RAWG requires an active hyperlink.
  String get attributionUrl;

  /// Whether a lookup can even be attempted — false when a key is missing.
  bool get isConfigured;

  Future<List<EnrichmentSuggestion>> search(String query);
}
