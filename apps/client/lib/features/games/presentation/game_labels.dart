import '../../../l10n/app_localizations.dart';
import '../domain/game.dart';

String gameStatusLabel(AppLocalizations l10n, GameStatus status) {
  return switch (status) {
    GameStatus.playing => l10n.statusPlaying,
    GameStatus.finished => l10n.statusFinished,
    GameStatus.hundredPercent => l10n.statusHundredPercent,
    GameStatus.dropped => l10n.statusDropped,
  };
}
