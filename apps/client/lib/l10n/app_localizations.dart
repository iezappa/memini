import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Memini'**
  String get appTitle;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greeting(String name);

  /// No description provided for @greetingAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Your collection'**
  String get greetingAnonymous;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search rooms, notes, reviews'**
  String get searchHint;

  /// No description provided for @roomCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No rooms} =1{1 room} other{{count} rooms}}'**
  String roomCount(int count);

  /// No description provided for @filterEscaped.
  ///
  /// In en, this message translates to:
  /// **'Escaped'**
  String get filterEscaped;

  /// No description provided for @filterFailed.
  ///
  /// In en, this message translates to:
  /// **'Not escaped'**
  String get filterFailed;

  /// No description provided for @filterFranchise.
  ///
  /// In en, this message translates to:
  /// **'Franchise'**
  String get filterFranchise;

  /// No description provided for @filterAllFranchises.
  ///
  /// In en, this message translates to:
  /// **'All franchises'**
  String get filterAllFranchises;

  /// No description provided for @sortRatingHigh.
  ///
  /// In en, this message translates to:
  /// **'Highest score'**
  String get sortRatingHigh;

  /// No description provided for @sortRatingLow.
  ///
  /// In en, this message translates to:
  /// **'Lowest score'**
  String get sortRatingLow;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the first room you played and start building your record.'**
  String get emptyBody;

  /// No description provided for @emptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No room matches these filters.'**
  String get emptyFiltered;

  /// No description provided for @addRoom.
  ///
  /// In en, this message translates to:
  /// **'Add room'**
  String get addRoom;

  /// No description provided for @editRoom.
  ///
  /// In en, this message translates to:
  /// **'Edit room'**
  String get editRoom;

  /// No description provided for @newRoom.
  ///
  /// In en, this message translates to:
  /// **'New room'**
  String get newRoom;

  /// No description provided for @deleteRoom.
  ///
  /// In en, this message translates to:
  /// **'Delete room'**
  String get deleteRoom;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String deleteConfirm(String name);

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldNameRequired.
  ///
  /// In en, this message translates to:
  /// **'A room needs a name.'**
  String get fieldNameRequired;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldFranchise.
  ///
  /// In en, this message translates to:
  /// **'Franchise'**
  String get fieldFranchise;

  /// No description provided for @fieldRating.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get fieldRating;

  /// No description provided for @fieldReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get fieldReview;

  /// No description provided for @fieldPlayedOn.
  ///
  /// In en, this message translates to:
  /// **'Played on'**
  String get fieldPlayedOn;

  /// No description provided for @fieldOutcome.
  ///
  /// In en, this message translates to:
  /// **'Did you escape?'**
  String get fieldOutcome;

  /// No description provided for @fieldTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left (minutes)'**
  String get fieldTimeLeft;

  /// No description provided for @fieldTimeLeftHint.
  ///
  /// In en, this message translates to:
  /// **'Only if you escaped'**
  String get fieldTimeLeftHint;

  /// No description provided for @franchiseHint.
  ///
  /// In en, this message translates to:
  /// **'Type a name; it is created if new'**
  String get franchiseHint;

  /// No description provided for @franchises.
  ///
  /// In en, this message translates to:
  /// **'Franchises'**
  String get franchises;

  /// No description provided for @notRated.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get notRated;

  /// No description provided for @escapedYes.
  ///
  /// In en, this message translates to:
  /// **'Escaped'**
  String get escapedYes;

  /// No description provided for @escapedNo.
  ///
  /// In en, this message translates to:
  /// **'Did not escape'**
  String get escapedNo;

  /// No description provided for @timeLeftValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String timeLeftValue(int minutes);

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log a room and your stats will show up here.'**
  String get statsEmpty;

  /// No description provided for @statsEscapeRate.
  ///
  /// In en, this message translates to:
  /// **'Escape rate'**
  String get statsEscapeRate;

  /// No description provided for @statsAverage.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get statsAverage;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get settingsAccent;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @settingsDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settingsDisplayName;

  /// No description provided for @settingsDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Used in the greeting'**
  String get settingsDisplayNameHint;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsPinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN lock'**
  String get settingsPinLock;

  /// No description provided for @settingsPinLockOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsPinLockOff;

  /// No description provided for @settingsPinLockOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsPinLockOn;

  /// No description provided for @pinSet.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get pinSet;

  /// No description provided for @pinChange.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get pinChange;

  /// No description provided for @pinDisable.
  ///
  /// In en, this message translates to:
  /// **'Turn off PIN'**
  String get pinDisable;

  /// No description provided for @pinEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pinEnter;

  /// No description provided for @pinCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get pinCurrent;

  /// No description provided for @pinNew.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get pinNew;

  /// No description provided for @pinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Repeat the PIN'**
  String get pinConfirm;

  /// No description provided for @pinTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 4 digits.'**
  String get pinTooShort;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two PINs do not match.'**
  String get pinMismatch;

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN.'**
  String get pinWrong;

  /// No description provided for @pinUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get pinUnlock;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsData;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export backup (JSON)'**
  String get exportJson;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as spreadsheet (CSV)'**
  String get exportCsv;

  /// No description provided for @importJson.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importJson;

  /// No description provided for @importWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace everything?'**
  String get importWarningTitle;

  /// No description provided for @importWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Importing replaces every room and franchise currently stored. Export a backup first if you want to keep them.'**
  String get importWarningBody;

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get importConfirm;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 room restored} other{{count} rooms restored}}'**
  String importDone(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'That file is not a valid Memini backup.'**
  String get importFailed;

  /// No description provided for @exportDone.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get exportDone;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the file.'**
  String get exportFailed;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'What Memini is'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Memini is a personal log of the things you have done — escape rooms, meals out, concerts, films and series, and games. It stores everything on this device only — no account, no server, no sync. If you uninstall the app or lose the device, the data goes with it, so export a backup regularly. Scores and reviews are your own opinion and are never shared with anyone.'**
  String get disclaimerBody;

  /// No description provided for @disclaimerAccept.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get disclaimerAccept;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support my projects'**
  String get supportTitle;

  /// No description provided for @supportBody.
  ///
  /// In en, this message translates to:
  /// **'Memini is free and stays that way. If it is useful to you, you can buy me a coffee.'**
  String get supportBody;

  /// No description provided for @supportCafecito.
  ///
  /// In en, this message translates to:
  /// **'Cafecito (Argentina)'**
  String get supportCafecito;

  /// No description provided for @supportPatreon.
  ///
  /// In en, this message translates to:
  /// **'Patreon (worldwide)'**
  String get supportPatreon;

  /// No description provided for @linkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get linkFailed;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// No description provided for @tutorialAgain.
  ///
  /// In en, this message translates to:
  /// **'Show the tutorial again'**
  String get tutorialAgain;

  /// No description provided for @tutorial1Title.
  ///
  /// In en, this message translates to:
  /// **'Everything you did, in one place'**
  String get tutorial1Title;

  /// No description provided for @tutorial1Body.
  ///
  /// In en, this message translates to:
  /// **'Log escape rooms, meals, concerts, films, series and games: the date and the details that matter for each one.'**
  String get tutorial1Body;

  /// No description provided for @tutorial2Title.
  ///
  /// In en, this message translates to:
  /// **'Score them like a critic'**
  String get tutorial2Title;

  /// No description provided for @tutorial2Body.
  ///
  /// In en, this message translates to:
  /// **'Give each entry a score out of 10 and write the review you would have wanted to read beforehand.'**
  String get tutorial2Body;

  /// No description provided for @tutorial3Title.
  ///
  /// In en, this message translates to:
  /// **'Yours alone'**
  String get tutorial3Title;

  /// No description provided for @tutorial3Body.
  ///
  /// In en, this message translates to:
  /// **'Everything lives on this device. Export a backup whenever you want to keep it safe.'**
  String get tutorial3Body;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Everything worth remembering'**
  String get homeTagline;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently logged'**
  String get homeRecent;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Pick a section above and add the first one.'**
  String get homeRecentEmpty;

  /// No description provided for @domainRooms.
  ///
  /// In en, this message translates to:
  /// **'Escape rooms'**
  String get domainRooms;

  /// No description provided for @domainDining.
  ///
  /// In en, this message translates to:
  /// **'Places I ate'**
  String get domainDining;

  /// No description provided for @domainConcerts.
  ///
  /// In en, this message translates to:
  /// **'Bands I saw'**
  String get domainConcerts;

  /// No description provided for @domainScreen.
  ///
  /// In en, this message translates to:
  /// **'Films and series'**
  String get domainScreen;

  /// No description provided for @domainGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get domainGames;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title A–Z'**
  String get sortTitle;

  /// No description provided for @sortDateNewest.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get sortDateNewest;

  /// No description provided for @sortDateOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortDateOldest;

  /// No description provided for @mealCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No meals} =1{1 meal} other{{count} meals}}'**
  String mealCount(int count);

  /// No description provided for @mealSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places, dishes, notes'**
  String get mealSearchHint;

  /// No description provided for @mealEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No meals logged'**
  String get mealEmptyTitle;

  /// No description provided for @mealEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Log a place the moment you leave it, while the dish is still fresh.'**
  String get mealEmptyBody;

  /// No description provided for @mealEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No meal matches these filters'**
  String get mealEmptyFiltered;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMeal;

  /// No description provided for @newMeal.
  ///
  /// In en, this message translates to:
  /// **'New meal'**
  String get newMeal;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get editMeal;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get deleteMeal;

  /// No description provided for @fieldPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get fieldPlace;

  /// No description provided for @fieldPlaceRequired.
  ///
  /// In en, this message translates to:
  /// **'The place needs a name'**
  String get fieldPlaceRequired;

  /// No description provided for @fieldDish.
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get fieldDish;

  /// No description provided for @fieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get fieldPrice;

  /// No description provided for @fieldCompany.
  ///
  /// In en, this message translates to:
  /// **'With'**
  String get fieldCompany;

  /// No description provided for @fieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Neighbourhood or city'**
  String get fieldLocation;

  /// No description provided for @filterLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filterLocation;

  /// No description provided for @filterAllLocations.
  ///
  /// In en, this message translates to:
  /// **'Anywhere'**
  String get filterAllLocations;

  /// No description provided for @gigCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No gigs} =1{1 gig} other{{count} gigs}}'**
  String gigCount(int count);

  /// No description provided for @gigSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search bands, venues, notes'**
  String get gigSearchHint;

  /// No description provided for @gigEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No gigs logged'**
  String get gigEmptyTitle;

  /// No description provided for @gigEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Write down the night while you can still hear it.'**
  String get gigEmptyBody;

  /// No description provided for @gigEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No gig matches these filters'**
  String get gigEmptyFiltered;

  /// No description provided for @addGig.
  ///
  /// In en, this message translates to:
  /// **'Add gig'**
  String get addGig;

  /// No description provided for @newGig.
  ///
  /// In en, this message translates to:
  /// **'New gig'**
  String get newGig;

  /// No description provided for @editGig.
  ///
  /// In en, this message translates to:
  /// **'Edit gig'**
  String get editGig;

  /// No description provided for @deleteGig.
  ///
  /// In en, this message translates to:
  /// **'Delete gig'**
  String get deleteGig;

  /// No description provided for @fieldBand.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get fieldBand;

  /// No description provided for @fieldBandRequired.
  ///
  /// In en, this message translates to:
  /// **'The band needs a name'**
  String get fieldBandRequired;

  /// No description provided for @fieldVenue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get fieldVenue;

  /// No description provided for @fieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldCity;

  /// No description provided for @fieldSupportActs.
  ///
  /// In en, this message translates to:
  /// **'Support acts'**
  String get fieldSupportActs;

  /// No description provided for @fieldSupportActsHint.
  ///
  /// In en, this message translates to:
  /// **'Separate them with commas'**
  String get fieldSupportActsHint;

  /// No description provided for @fieldSetlist.
  ///
  /// In en, this message translates to:
  /// **'Setlist'**
  String get fieldSetlist;

  /// No description provided for @fieldSetlistHint.
  ///
  /// In en, this message translates to:
  /// **'One song per line'**
  String get fieldSetlistHint;

  /// No description provided for @filterCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get filterCity;

  /// No description provided for @filterAllCities.
  ///
  /// In en, this message translates to:
  /// **'Everywhere'**
  String get filterAllCities;

  /// No description provided for @viewingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing watched} =1{1 title} other{{count} titles}}'**
  String viewingCount(int count);

  /// No description provided for @viewingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search titles, directors, notes'**
  String get viewingSearchHint;

  /// No description provided for @viewingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing watched yet'**
  String get viewingEmptyTitle;

  /// No description provided for @viewingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Log what you watch and the year will tell you a story.'**
  String get viewingEmptyBody;

  /// No description provided for @viewingEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get viewingEmptyFiltered;

  /// No description provided for @addViewing.
  ///
  /// In en, this message translates to:
  /// **'Add title'**
  String get addViewing;

  /// No description provided for @newViewing.
  ///
  /// In en, this message translates to:
  /// **'New title'**
  String get newViewing;

  /// No description provided for @editViewing.
  ///
  /// In en, this message translates to:
  /// **'Edit title'**
  String get editViewing;

  /// No description provided for @deleteViewing.
  ///
  /// In en, this message translates to:
  /// **'Delete title'**
  String get deleteViewing;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'It needs a title'**
  String get fieldTitleRequired;

  /// No description provided for @fieldKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get fieldKind;

  /// No description provided for @kindFilm.
  ///
  /// In en, this message translates to:
  /// **'Film'**
  String get kindFilm;

  /// No description provided for @kindSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get kindSeries;

  /// No description provided for @kindMiniseries.
  ///
  /// In en, this message translates to:
  /// **'Miniseries'**
  String get kindMiniseries;

  /// No description provided for @kindDocumentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get kindDocumentary;

  /// No description provided for @fieldReleaseYear.
  ///
  /// In en, this message translates to:
  /// **'Release year'**
  String get fieldReleaseYear;

  /// No description provided for @fieldDirector.
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get fieldDirector;

  /// No description provided for @fieldCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get fieldCast;

  /// No description provided for @fieldCastHint.
  ///
  /// In en, this message translates to:
  /// **'Separate them with commas'**
  String get fieldCastHint;

  /// No description provided for @fieldSeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get fieldSeason;

  /// No description provided for @seasonValue.
  ///
  /// In en, this message translates to:
  /// **'Season {number}'**
  String seasonValue(int number);

  /// No description provided for @fieldWatchedOn.
  ///
  /// In en, this message translates to:
  /// **'Watched on'**
  String get fieldWatchedOn;

  /// No description provided for @filterKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get filterKind;

  /// No description provided for @filterAllKinds.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get filterAllKinds;

  /// No description provided for @gameCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No games} =1{1 game} other{{count} games}}'**
  String gameCount(int count);

  /// No description provided for @gameSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search games, platforms, notes'**
  String get gameSearchHint;

  /// No description provided for @gameEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No games logged'**
  String get gameEmptyTitle;

  /// No description provided for @gameEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Dropping a game is a verdict too. Log it anyway.'**
  String get gameEmptyBody;

  /// No description provided for @gameEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No game matches these filters'**
  String get gameEmptyFiltered;

  /// No description provided for @addGame.
  ///
  /// In en, this message translates to:
  /// **'Add game'**
  String get addGame;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// No description provided for @editGame.
  ///
  /// In en, this message translates to:
  /// **'Edit game'**
  String get editGame;

  /// No description provided for @deleteGame.
  ///
  /// In en, this message translates to:
  /// **'Delete game'**
  String get deleteGame;

  /// No description provided for @fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fieldStatus;

  /// No description provided for @statusPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get statusPlaying;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @statusHundredPercent.
  ///
  /// In en, this message translates to:
  /// **'100%'**
  String get statusHundredPercent;

  /// No description provided for @statusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// No description provided for @fieldPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get fieldPlatform;

  /// No description provided for @fieldHoursPlayed.
  ///
  /// In en, this message translates to:
  /// **'Hours played'**
  String get fieldHoursPlayed;

  /// No description provided for @fieldPlayedUntil.
  ///
  /// In en, this message translates to:
  /// **'Last played'**
  String get fieldPlayedUntil;

  /// No description provided for @hoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String hoursValue(String hours);

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @filterAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'Any status'**
  String get filterAllStatuses;

  /// No description provided for @filterPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get filterPlatform;

  /// No description provided for @filterAllPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Any platform'**
  String get filterAllPlatforms;

  /// No description provided for @fieldAte.
  ///
  /// In en, this message translates to:
  /// **'Eaten on'**
  String get fieldAte;

  /// No description provided for @fieldSawOn.
  ///
  /// In en, this message translates to:
  /// **'Seen on'**
  String get fieldSawOn;

  /// No description provided for @enrich.
  ///
  /// In en, this message translates to:
  /// **'Look up details'**
  String get enrich;

  /// No description provided for @enrichSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get enrichSearching;

  /// No description provided for @enrichNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found. Fill it in by hand.'**
  String get enrichNoResults;

  /// No description provided for @enrichOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. You can still fill it in by hand.'**
  String get enrichOffline;

  /// No description provided for @enrichFailed.
  ///
  /// In en, this message translates to:
  /// **'The lookup failed. You can still fill it in by hand.'**
  String get enrichFailed;

  /// No description provided for @enrichCredit.
  ///
  /// In en, this message translates to:
  /// **'Data from {source}'**
  String enrichCredit(String source);

  /// No description provided for @statsEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get statsEntries;

  /// No description provided for @statsRated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get statsRated;

  /// No description provided for @statsByDomain.
  ///
  /// In en, this message translates to:
  /// **'By section'**
  String get statsByDomain;

  /// No description provided for @statsBestOverall.
  ///
  /// In en, this message translates to:
  /// **'Your highest score'**
  String get statsBestOverall;

  /// No description provided for @statsPerYearAll.
  ///
  /// In en, this message translates to:
  /// **'Entries per year'**
  String get statsPerYearAll;

  /// No description provided for @statsHoursPlayed.
  ///
  /// In en, this message translates to:
  /// **'Hours played'**
  String get statsHoursPlayed;

  /// No description provided for @statsMoneySpent.
  ///
  /// In en, this message translates to:
  /// **'Spent on meals'**
  String get statsMoneySpent;

  /// No description provided for @statsNothingRated.
  ///
  /// In en, this message translates to:
  /// **'Nothing rated yet'**
  String get statsNothingRated;

  /// No description provided for @enrichMissingKey.
  ///
  /// In en, this message translates to:
  /// **'No lookup key set. Add one in Settings, or fill it in by hand.'**
  String get enrichMissingKey;

  /// No description provided for @settingsLookups.
  ///
  /// In en, this message translates to:
  /// **'Lookups'**
  String get settingsLookups;

  /// No description provided for @settingsLookupsBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Paste your own free keys to fill in details automatically. Memini works fully without them.'**
  String get settingsLookupsBody;

  /// No description provided for @settingsTmdbKey.
  ///
  /// In en, this message translates to:
  /// **'TMDB key (films and series)'**
  String get settingsTmdbKey;

  /// No description provided for @settingsRawgKey.
  ///
  /// In en, this message translates to:
  /// **'RAWG key (games)'**
  String get settingsRawgKey;

  /// No description provided for @settingsKeyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsKeyNotSet;

  /// No description provided for @settingsKeySet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get settingsKeySet;

  /// No description provided for @settingsMusicBrainzNote.
  ///
  /// In en, this message translates to:
  /// **'Bands use MusicBrainz, which needs no key.'**
  String get settingsMusicBrainzNote;

  /// No description provided for @storageDegradedWarning.
  ///
  /// In en, this message translates to:
  /// **'This browser keeps your data in storage that may be lost on a reload or when browser data is cleared. Export a backup now.'**
  String get storageDegradedWarning;

  /// No description provided for @storageVolatileWarning.
  ///
  /// In en, this message translates to:
  /// **'This browser cannot store your data: everything you record will be lost when you close this tab. Export a backup before you leave.'**
  String get storageVolatileWarning;

  /// No description provided for @storageExportNow.
  ///
  /// In en, this message translates to:
  /// **'Export now'**
  String get storageExportNow;

  /// No description provided for @storageWarningDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get storageWarningDismiss;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'The local database could not be opened'**
  String get recoveryTitle;

  /// No description provided for @recoveryBody.
  ///
  /// In en, this message translates to:
  /// **'The data stored on this device could not be read, so the app cannot start normally. You can restore a backup file, or start over with an empty database.'**
  String get recoveryBody;

  /// No description provided for @recoveryImport.
  ///
  /// In en, this message translates to:
  /// **'Import a backup'**
  String get recoveryImport;

  /// No description provided for @recoveryReset.
  ///
  /// In en, this message translates to:
  /// **'Reset local database'**
  String get recoveryReset;

  /// No description provided for @recoveryImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import a backup?'**
  String get recoveryImportConfirmTitle;

  /// No description provided for @recoveryImportConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The unreadable database on this device will be permanently deleted and replaced by what the backup file holds. It cannot be undone.'**
  String get recoveryImportConfirmBody;

  /// No description provided for @recoveryResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset the local database?'**
  String get recoveryResetConfirmTitle;

  /// No description provided for @recoveryResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Everything stored on this device will be permanently deleted and the app will start empty. It cannot be undone.'**
  String get recoveryResetConfirmBody;

  /// No description provided for @recoveryResetConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get recoveryResetConfirmAction;

  /// No description provided for @backupNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data lives only on this device'**
  String get backupNoticeTitle;

  /// No description provided for @backupNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Memini isn\'t stored on any server. If you uninstall the app, lose or reset your device, or clear your browser data, everything you recorded is gone. Export a backup regularly from Settings → Your data and keep the file somewhere else.'**
  String get backupNoticeBody;

  /// No description provided for @backupNoticeCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand, and I\'ll export backups'**
  String get backupNoticeCheckbox;

  /// No description provided for @backupNoticeAccept.
  ///
  /// In en, this message translates to:
  /// **'Got it, I\'ll back up'**
  String get backupNoticeAccept;

  /// No description provided for @backupNoticeSettings.
  ///
  /// In en, this message translates to:
  /// **'Your data isn\'t stored on any server. Export regularly and keep the file off this device.'**
  String get backupNoticeSettings;

  /// No description provided for @backupReminderNever.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t backed up your data yet.'**
  String get backupReminderNever;

  /// No description provided for @backupReminderOverdue.
  ///
  /// In en, this message translates to:
  /// **'Your last backup was {days} days ago.'**
  String backupReminderOverdue(int days);

  /// No description provided for @backupReminderAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get backupReminderAction;

  /// No description provided for @backupReminderDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get backupReminderDismiss;

  /// No description provided for @importExportFirst.
  ///
  /// In en, this message translates to:
  /// **'Export current data first'**
  String get importExportFirst;

  /// No description provided for @eraseAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all my data'**
  String get eraseAllData;

  /// No description provided for @eraseAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all your data?'**
  String get eraseAllTitle;

  /// No description provided for @eraseAllBody.
  ///
  /// In en, this message translates to:
  /// **'Every entry and franchise on this device is deleted, along with your PIN, your name, your lookup keys and your settings; only the language and the appearance are kept. The app then starts over from the welcome screens. It cannot be undone, and no copy exists anywhere else: export first if you might want any of it back.'**
  String get eraseAllBody;

  /// No description provided for @eraseAllConfirmWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get eraseAllConfirmWord;

  /// No description provided for @eraseAllTypeToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm'**
  String eraseAllTypeToConfirm(String word);

  /// No description provided for @eraseAllExportFirst.
  ///
  /// In en, this message translates to:
  /// **'Export first'**
  String get eraseAllExportFirst;

  /// No description provided for @eraseAllAction.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get eraseAllAction;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @developerContact.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerContact;

  /// No description provided for @developerContactHint.
  ///
  /// In en, this message translates to:
  /// **'Questions and reports: the project\'s issue tracker'**
  String get developerContactHint;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get openSourceLicenses;

  /// No description provided for @whatsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new in {version}'**
  String whatsNewTitle(String version);

  /// No description provided for @whatsNewClose.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get whatsNewClose;

  /// No description provided for @releaseNotesHistory.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get releaseNotesHistory;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutVersionHint.
  ///
  /// In en, this message translates to:
  /// **'See what changed in each release'**
  String get aboutVersionHint;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available.'**
  String updateAvailableBody(String version);

  /// No description provided for @updateAvailableBackupHint.
  ///
  /// In en, this message translates to:
  /// **'This version changes how your data is stored. Export a backup before updating.'**
  String get updateAvailableBackupHint;

  /// No description provided for @updateUnsupportedPath.
  ///
  /// In en, this message translates to:
  /// **'Your version is too old to update directly. Export a backup and check the instructions.'**
  String get updateUnsupportedPath;

  /// No description provided for @updateActionReload.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateActionReload;

  /// No description provided for @updateActionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateActionDownload;

  /// No description provided for @updateActionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get updateActionExport;

  /// No description provided for @updateActionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get updateActionDismiss;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
