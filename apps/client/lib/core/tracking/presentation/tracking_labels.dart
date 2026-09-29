import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/tracked_domain.dart';
import '../domain/tracking_filter.dart';

export '../domain/tracked_domain.dart';

/// The ordering labels, written once for all domains.
String trackingSortLabel(AppLocalizations l10n, TrackingSort sort) {
  return switch (sort) {
    TrackingSort.happenedOnDesc => l10n.sortDateNewest,
    TrackingSort.happenedOnAsc => l10n.sortDateOldest,
    TrackingSort.ratingDesc => l10n.sortRatingHigh,
    TrackingSort.ratingAsc => l10n.sortRatingLow,
    TrackingSort.titleAsc => l10n.sortTitle,
  };
}

extension TrackedDomainPresentation on TrackedDomain {
  String label(AppLocalizations l10n) => switch (this) {
    TrackedDomain.rooms => l10n.domainRooms,
    TrackedDomain.dining => l10n.domainDining,
    TrackedDomain.concerts => l10n.domainConcerts,
    TrackedDomain.screen => l10n.domainScreen,
    TrackedDomain.games => l10n.domainGames,
    TrackedDomain.books => l10n.domainBooks,
  };

  IconData get icon => switch (this) {
    TrackedDomain.rooms => Icons.meeting_room_outlined,
    TrackedDomain.dining => Icons.restaurant_outlined,
    TrackedDomain.concerts => Icons.music_note_outlined,
    TrackedDomain.screen => Icons.movie_outlined,
    TrackedDomain.games => Icons.sports_esports_outlined,
    TrackedDomain.books => Icons.menu_book_outlined,
  };

  String get route => switch (this) {
    TrackedDomain.rooms => '/rooms',
    TrackedDomain.dining => '/meals',
    TrackedDomain.concerts => '/gigs',
    TrackedDomain.screen => '/viewings',
    TrackedDomain.games => '/games',
    TrackedDomain.books => '/books',
  };
}
