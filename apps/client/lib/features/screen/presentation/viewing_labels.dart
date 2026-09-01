import '../../../l10n/app_localizations.dart';
import '../domain/viewing.dart';

String viewingKindLabel(AppLocalizations l10n, ViewingKind kind) {
  return switch (kind) {
    ViewingKind.film => l10n.kindFilm,
    ViewingKind.series => l10n.kindSeries,
    ViewingKind.miniseries => l10n.kindMiniseries,
    ViewingKind.documentary => l10n.kindDocumentary,
  };
}
