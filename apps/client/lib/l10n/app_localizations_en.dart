// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Memini';

  @override
  String get navCollection => 'Collection';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get greetingAnonymous => 'Your collection';

  @override
  String get searchHint => 'Search rooms, notes, reviews';

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '1 room',
      zero: 'No rooms',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filters';

  @override
  String get filterOutcome => 'Outcome';

  @override
  String get filterAny => 'Any';

  @override
  String get filterEscaped => 'Escaped';

  @override
  String get filterFailed => 'Not escaped';

  @override
  String get filterFranchise => 'Franchise';

  @override
  String get filterAllFranchises => 'All franchises';

  @override
  String get filterMinRating => 'Minimum score';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortPlayedNewest => 'Most recent';

  @override
  String get sortPlayedOldest => 'Oldest';

  @override
  String get sortRatingHigh => 'Highest score';

  @override
  String get sortRatingLow => 'Lowest score';

  @override
  String get sortName => 'Name';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get emptyTitle => 'Nothing logged yet';

  @override
  String get emptyBody =>
      'Add the first room you played and start building your record.';

  @override
  String get emptyFiltered => 'No room matches these filters.';

  @override
  String get addRoom => 'Add room';

  @override
  String get editRoom => 'Edit room';

  @override
  String get newRoom => 'New room';

  @override
  String get deleteRoom => 'Delete room';

  @override
  String deleteRoomConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get fieldName => 'Name';

  @override
  String get fieldNameRequired => 'A room needs a name.';

  @override
  String get fieldPhoto => 'Photo';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldFranchise => 'Franchise';

  @override
  String get fieldRating => 'Score';

  @override
  String get fieldReview => 'Review';

  @override
  String get fieldPlayedOn => 'Played on';

  @override
  String get fieldOutcome => 'Did you escape?';

  @override
  String get fieldTimeLeft => 'Time left (minutes)';

  @override
  String get fieldTimeLeftHint => 'Only if you escaped';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get photoReplace => 'Replace photo';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get photoFailed => 'Could not load that image.';

  @override
  String get franchiseNone => 'No franchise';

  @override
  String get franchiseHint => 'Type a name; it is created if new';

  @override
  String get franchises => 'Franchises';

  @override
  String franchiseRoomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '1 room',
      zero: 'no rooms',
    );
    return '$_temp0';
  }

  @override
  String get notRated => 'Not rated';

  @override
  String get escapedYes => 'Escaped';

  @override
  String get escapedNo => 'Did not escape';

  @override
  String timeLeftValue(int minutes) {
    return '$minutes min left';
  }

  @override
  String get statsEmpty => 'Log a room and your stats will show up here.';

  @override
  String get statsTotal => 'Rooms played';

  @override
  String get statsEscaped => 'Escaped';

  @override
  String get statsEscapeRate => 'Escape rate';

  @override
  String get statsAverage => 'Average score';

  @override
  String get statsBest => 'Highest rated';

  @override
  String get statsPerYear => 'Rooms per year';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsDisplayName => 'Your name';

  @override
  String get settingsDisplayNameHint => 'Used in the greeting';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsPinLock => 'PIN lock';

  @override
  String get settingsPinLockOff => 'Off';

  @override
  String get settingsPinLockOn => 'On';

  @override
  String get pinSet => 'Set a PIN';

  @override
  String get pinChange => 'Change PIN';

  @override
  String get pinDisable => 'Turn off PIN';

  @override
  String get pinEnter => 'Enter your PIN';

  @override
  String get pinCurrent => 'Current PIN';

  @override
  String get pinNew => 'New PIN';

  @override
  String get pinConfirm => 'Repeat the PIN';

  @override
  String get pinTooShort => 'Use at least 4 digits.';

  @override
  String get pinDigitsOnly => 'Digits only.';

  @override
  String get pinMismatch => 'The two PINs do not match.';

  @override
  String get pinWrong => 'Wrong PIN.';

  @override
  String get pinUnlock => 'Unlock';

  @override
  String get settingsData => 'Your data';

  @override
  String get exportJson => 'Export backup (JSON)';

  @override
  String get exportCsv => 'Export as spreadsheet (CSV)';

  @override
  String get importJson => 'Import backup';

  @override
  String get importWarningTitle => 'Replace everything?';

  @override
  String get importWarningBody =>
      'Importing replaces every room and franchise currently stored. Export a backup first if you want to keep them.';

  @override
  String get importConfirm => 'Replace';

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms restored',
      one: '1 room restored',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'That file is not a valid Memini backup.';

  @override
  String get exportDone => 'Backup saved.';

  @override
  String get exportFailed => 'Could not save the file.';

  @override
  String get settingsAbout => 'About';

  @override
  String get disclaimerTitle => 'What Memini is';

  @override
  String get disclaimerBody =>
      'Memini is a personal log of the things you have done — escape rooms, meals out, concerts, films and series, and games. It stores everything on this device only — no account, no server, no sync. If you uninstall the app or lose the device, the data goes with it, so export a backup regularly. Scores and reviews are your own opinion and are never shared with anyone.';

  @override
  String get disclaimerAccept => 'I understand';

  @override
  String get supportTitle => 'Support my projects';

  @override
  String get supportBody =>
      'Memini is free and stays that way. If it is useful to you, you can buy me a coffee.';

  @override
  String get supportCafecito => 'Cafecito (Argentina)';

  @override
  String get supportPatreon => 'Patreon (worldwide)';

  @override
  String get linkFailed => 'Could not open the link.';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialStart => 'Get started';

  @override
  String get tutorialAgain => 'Show the tutorial again';

  @override
  String get tutorial1Title => 'Everything you did, in one place';

  @override
  String get tutorial1Body =>
      'Log escape rooms, meals, concerts, films, series and games: a photo, the date and the details that matter for each one.';

  @override
  String get tutorial2Title => 'Score them like a critic';

  @override
  String get tutorial2Body =>
      'Give each entry a score out of 10 and write the review you would have wanted to read beforehand.';

  @override
  String get tutorial3Title => 'Yours alone';

  @override
  String get tutorial3Body =>
      'Everything lives on this device. Export a backup whenever you want to keep it safe.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get navHome => 'Home';

  @override
  String get homeTagline => 'Everything worth remembering';

  @override
  String get homeRecent => 'Recently logged';

  @override
  String get homeRecentEmpty =>
      'Nothing logged yet. Pick a section above and add the first one.';

  @override
  String get domainRooms => 'Escape rooms';

  @override
  String get domainDining => 'Places I ate';

  @override
  String get domainConcerts => 'Bands I saw';

  @override
  String get domainScreen => 'Films and series';

  @override
  String get domainGames => 'Games';

  @override
  String get sortTitle => 'Title A–Z';

  @override
  String get sortDateNewest => 'Most recent';

  @override
  String get sortDateOldest => 'Oldest';

  @override
  String mealCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
      zero: 'No meals',
    );
    return '$_temp0';
  }

  @override
  String get mealSearchHint => 'Search places, dishes, notes';

  @override
  String get mealEmptyTitle => 'No meals logged';

  @override
  String get mealEmptyBody =>
      'Log a place the moment you leave it, while the dish is still fresh.';

  @override
  String get mealEmptyFiltered => 'No meal matches these filters';

  @override
  String get addMeal => 'Add meal';

  @override
  String get newMeal => 'New meal';

  @override
  String get editMeal => 'Edit meal';

  @override
  String get deleteMeal => 'Delete meal';

  @override
  String get deleteMealConfirm =>
      'This meal will be removed from your log. This cannot be undone.';

  @override
  String get fieldPlace => 'Place';

  @override
  String get fieldPlaceRequired => 'The place needs a name';

  @override
  String get fieldDish => 'Dish';

  @override
  String get fieldPrice => 'Price';

  @override
  String get fieldCompany => 'With';

  @override
  String get fieldLocation => 'Neighbourhood or city';

  @override
  String get filterLocation => 'Location';

  @override
  String get filterAllLocations => 'Anywhere';

  @override
  String gigCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gigs',
      one: '1 gig',
      zero: 'No gigs',
    );
    return '$_temp0';
  }

  @override
  String get gigSearchHint => 'Search bands, venues, notes';

  @override
  String get gigEmptyTitle => 'No gigs logged';

  @override
  String get gigEmptyBody =>
      'Write down the night while you can still hear it.';

  @override
  String get gigEmptyFiltered => 'No gig matches these filters';

  @override
  String get addGig => 'Add gig';

  @override
  String get newGig => 'New gig';

  @override
  String get editGig => 'Edit gig';

  @override
  String get deleteGig => 'Delete gig';

  @override
  String get deleteGigConfirm =>
      'This gig will be removed from your log. This cannot be undone.';

  @override
  String get fieldBand => 'Band';

  @override
  String get fieldBandRequired => 'The band needs a name';

  @override
  String get fieldVenue => 'Venue';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldSupportActs => 'Support acts';

  @override
  String get fieldSupportActsHint => 'Separate them with commas';

  @override
  String get fieldSetlist => 'Setlist';

  @override
  String get fieldSetlistHint => 'One song per line';

  @override
  String get filterCity => 'City';

  @override
  String get filterAllCities => 'Everywhere';

  @override
  String viewingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
      zero: 'Nothing watched',
    );
    return '$_temp0';
  }

  @override
  String get viewingSearchHint => 'Search titles, directors, notes';

  @override
  String get viewingEmptyTitle => 'Nothing watched yet';

  @override
  String get viewingEmptyBody =>
      'Log what you watch and the year will tell you a story.';

  @override
  String get viewingEmptyFiltered => 'Nothing matches these filters';

  @override
  String get addViewing => 'Add title';

  @override
  String get newViewing => 'New title';

  @override
  String get editViewing => 'Edit title';

  @override
  String get deleteViewing => 'Delete title';

  @override
  String get deleteViewingConfirm =>
      'This title will be removed from your log. This cannot be undone.';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldTitleRequired => 'It needs a title';

  @override
  String get fieldKind => 'Kind';

  @override
  String get kindFilm => 'Film';

  @override
  String get kindSeries => 'Series';

  @override
  String get kindMiniseries => 'Miniseries';

  @override
  String get kindDocumentary => 'Documentary';

  @override
  String get fieldReleaseYear => 'Release year';

  @override
  String get fieldDirector => 'Director';

  @override
  String get fieldCast => 'Cast';

  @override
  String get fieldCastHint => 'Separate them with commas';

  @override
  String get fieldSeason => 'Season';

  @override
  String seasonValue(int number) {
    return 'Season $number';
  }

  @override
  String get fieldWatchedOn => 'Watched on';

  @override
  String get filterKind => 'Kind';

  @override
  String get filterAllKinds => 'Everything';

  @override
  String gameCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
      zero: 'No games',
    );
    return '$_temp0';
  }

  @override
  String get gameSearchHint => 'Search games, platforms, notes';

  @override
  String get gameEmptyTitle => 'No games logged';

  @override
  String get gameEmptyBody =>
      'Dropping a game is a verdict too. Log it anyway.';

  @override
  String get gameEmptyFiltered => 'No game matches these filters';

  @override
  String get addGame => 'Add game';

  @override
  String get newGame => 'New game';

  @override
  String get editGame => 'Edit game';

  @override
  String get deleteGame => 'Delete game';

  @override
  String get deleteGameConfirm =>
      'This game will be removed from your log. This cannot be undone.';

  @override
  String get fieldStatus => 'Status';

  @override
  String get statusPlaying => 'Playing';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusHundredPercent => '100%';

  @override
  String get statusDropped => 'Dropped';

  @override
  String get fieldPlatform => 'Platform';

  @override
  String get fieldHoursPlayed => 'Hours played';

  @override
  String get fieldPlayedUntil => 'Last played';

  @override
  String hoursValue(String hours) {
    return '${hours}h';
  }

  @override
  String get filterStatus => 'Status';

  @override
  String get filterAllStatuses => 'Any status';

  @override
  String get filterPlatform => 'Platform';

  @override
  String get filterAllPlatforms => 'Any platform';

  @override
  String get fieldAte => 'Eaten on';

  @override
  String get fieldSawOn => 'Seen on';

  @override
  String get enrich => 'Look up details';

  @override
  String get enrichSearching => 'Searching…';

  @override
  String get enrichNoResults => 'Nothing found. Fill it in by hand.';

  @override
  String get enrichOffline =>
      'No connection. You can still fill it in by hand.';

  @override
  String get enrichFailed =>
      'The lookup failed. You can still fill it in by hand.';

  @override
  String get enrichApply => 'Use this';

  @override
  String enrichCredit(String source) {
    return 'Data from $source';
  }

  @override
  String get statsOverview => 'Everything';

  @override
  String get statsEntries => 'Entries';

  @override
  String get statsRated => 'Rated';

  @override
  String get statsByDomain => 'By section';

  @override
  String get statsBestOverall => 'Your highest score';

  @override
  String get statsPerYearAll => 'Entries per year';

  @override
  String get statsRooms => 'Escape rooms';

  @override
  String get statsHoursPlayed => 'Hours played';

  @override
  String get statsMoneySpent => 'Spent on meals';

  @override
  String get statsNothingRated => 'Nothing rated yet';

  @override
  String get enrichMissingKey =>
      'No lookup key set. Add one in Settings, or fill it in by hand.';

  @override
  String get settingsLookups => 'Lookups';

  @override
  String get settingsLookupsBody =>
      'Optional. Paste your own free keys to fill in covers and details automatically. Memini works fully without them.';

  @override
  String get settingsTmdbKey => 'TMDB key (films and series)';

  @override
  String get settingsRawgKey => 'RAWG key (games)';

  @override
  String get settingsKeyNotSet => 'Not set';

  @override
  String get settingsKeySet => 'Set';

  @override
  String get settingsGetKey => 'Get a free key';

  @override
  String get settingsMusicBrainzNote =>
      'Bands use MusicBrainz, which needs no key.';
}
