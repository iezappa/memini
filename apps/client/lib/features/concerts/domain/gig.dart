import '../../../core/tracking/domain/trackable.dart';

/// A show the owner went to.
///
/// Keyed on the night, not the band: seeing the same act twice is two gigs,
/// and a festival day with six acts is one entry with the line-up in
/// [supportActs].
class Gig implements Trackable {
  const Gig({
    required this.id,
    this.updatedAt,
    required this.title,
    required this.happenedOn,
    this.description,
    this.rating,
    this.review,
    this.venue,
    this.city,
    this.supportActs,
    this.setlist,
    this.company,
    this.externalId,
  });

  @override
  final String id;

  @override
  final DateTime? updatedAt;

  /// The headliner.
  @override
  final String title;
  @override
  final String? description;
  @override
  final double? rating;
  @override
  final String? review;
  @override
  final DateTime happenedOn;

  final String? venue;
  final String? city;

  /// Opening acts, comma separated — or the whole line-up for a festival day.
  final String? supportActs;

  /// The songs played, one per line. Free text so a partly remembered set is
  /// still worth writing down.
  final String? setlist;
  final String? company;

  /// MusicBrainz id of the artist, cached when the owner enriched the entry.
  final String? externalId;

  @override
  bool get isRated => rating != null;

  Gig copyWith({
    String? title,
    String? description,
    double? rating,
    String? review,
    DateTime? happenedOn,
    String? venue,
    String? city,
    String? supportActs,
    String? setlist,
    String? company,
    String? externalId,
    bool clearRating = false,
    bool clearExternalId = false,
  }) {
    return Gig(
      id: id,
      updatedAt: updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: clearRating ? null : (rating ?? this.rating),
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      venue: venue ?? this.venue,
      city: city ?? this.city,
      supportActs: supportActs ?? this.supportActs,
      setlist: setlist ?? this.setlist,
      company: company ?? this.company,
      externalId: clearExternalId ? null : (externalId ?? this.externalId),
    );
  }
}

/// Input for creating a gig, before the store assigns an id.
class GigDraft {
  const GigDraft({
    required this.title,
    required this.happenedOn,
    this.description,
    this.rating,
    this.review,
    this.venue,
    this.city,
    this.supportActs,
    this.setlist,
    this.company,
    this.externalId,
  });

  final String title;
  final DateTime happenedOn;
  final String? description;
  final double? rating;
  final String? review;
  final String? venue;
  final String? city;
  final String? supportActs;
  final String? setlist;
  final String? company;
  final String? externalId;
}
