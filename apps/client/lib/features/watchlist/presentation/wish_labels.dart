import 'package:flutter/material.dart';

import '../../../core/tracking/domain/tracking_filter.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/wish.dart';

String wishKindLabel(AppLocalizations l10n, WishKind kind) => switch (kind) {
  WishKind.screen => l10n.wishKindScreen,
  WishKind.game => l10n.wishKindGame,
  WishKind.music => l10n.wishKindMusic,
};

/// The same icon the kind's own section uses, so a wish and the entry it
/// becomes look like the same thing.
IconData wishKindIcon(WishKind kind) => switch (kind) {
  WishKind.screen => Icons.movie_outlined,
  WishKind.game => Icons.sports_esports_outlined,
  WishKind.music => Icons.music_note_outlined,
};

/// What the button that fulfils a wish says. Three wordings, because "I have
/// seen it" is wrong for a game and wrong for a band.
String wishDoneLabel(AppLocalizations l10n, WishKind kind) => switch (kind) {
  WishKind.screen => l10n.wishDone,
  WishKind.game => l10n.wishDoneGame,
  WishKind.music => l10n.wishDoneMusic,
};

/// The three orderings a wish can have. The shared menu names the other two
/// after a score and a day it happened, and a wish has neither.
const kWishSorts = [
  TrackingSort.happenedOnDesc,
  TrackingSort.happenedOnAsc,
  TrackingSort.titleAsc,
];

String wishSortLabel(AppLocalizations l10n, TrackingSort sort) =>
    switch (sort) {
      TrackingSort.happenedOnAsc => l10n.watchlistSortOldest,
      TrackingSort.titleAsc => l10n.sortTitle,
      _ => l10n.watchlistSortNewest,
    };
