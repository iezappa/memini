import '../../../l10n/app_localizations.dart';
import '../domain/mood.dart';

export '../domain/mood.dart';

/// How each mood is worded. The genre it maps to is the domain's business.
String moodLabel(AppLocalizations l10n, Mood mood) => switch (mood) {
  Mood.laugh => l10n.moodLaugh,
  Mood.cry => l10n.moodCry,
  Mood.scare => l10n.moodScare,
  Mood.love => l10n.moodLove,
  Mood.thrill => l10n.moodThrill,
  Mood.elsewhere => l10n.moodElsewhere,
  Mood.learn => l10n.moodLearn,
  Mood.family => l10n.moodFamily,
};
