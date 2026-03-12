import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Lepa reč'**
  String get appTitle;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Title for the primer welcome screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Your Breathing Journey'**
  String get primerWelcomeTitle;

  /// Description text for the primer welcome screen
  ///
  /// In en, this message translates to:
  /// **'Find a quiet place where you can be present with yourself. This is your time.'**
  String get primerWelcomeDescription;

  /// Proceed button label
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// Title for the breathing exercise screen
  ///
  /// In en, this message translates to:
  /// **'Breathing Exercise'**
  String get breathingExercise;

  /// Instruction to breathe in
  ///
  /// In en, this message translates to:
  /// **'Breathe In'**
  String get breathIn;

  /// Instruction to breathe out
  ///
  /// In en, this message translates to:
  /// **'Breathe Out'**
  String get breathOut;

  /// Instruction to breathe in for a specific number of seconds
  ///
  /// In en, this message translates to:
  /// **'Breathe in for {seconds} seconds'**
  String breatheInForSeconds(int seconds);

  /// Instruction to breathe out for a specific number of seconds
  ///
  /// In en, this message translates to:
  /// **'Breathe out for {seconds} seconds'**
  String breatheOutForSeconds(int seconds);

  /// Instruction to hold breath
  ///
  /// In en, this message translates to:
  /// **'Hold your breath'**
  String get holdYourBreath;

  /// Label for breathing rounds
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// Complete button label
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Congratulatory message after session completion
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get sessionComplete;

  /// Detailed message after successfully completing a breathing session
  ///
  /// In en, this message translates to:
  /// **'You have completed your breathing exercise. You are doing amazing!'**
  String get sessionCompleteMessage;

  /// Continue button label to proceed to the next step
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToNext;

  /// Home page label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Dashboard page label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Loading indicator text for session data
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingSession;

  /// Title for the value statement selection screen
  ///
  /// In en, this message translates to:
  /// **'What matters most to you?'**
  String get valueStatementTitle;

  /// Title for the growth message screen
  ///
  /// In en, this message translates to:
  /// **'Your Growth Message'**
  String get growthMessageTitle;

  /// Button label to complete the primer
  ///
  /// In en, this message translates to:
  /// **'Complete Primer'**
  String get completePrimer;

  /// Error title when statements fail to load
  ///
  /// In en, this message translates to:
  /// **'Error Loading Statements'**
  String get errorLoadingStatements;

  /// Error message when value statements fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load value statements'**
  String get failedLoadValueStatements;

  /// Error title when growth message fails to load
  ///
  /// In en, this message translates to:
  /// **'Error Loading Message'**
  String get errorLoadingMessage;

  /// Error message when growth message fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load growth message'**
  String get failedLoadGrowthMessage;

  /// Retry button label to retry a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error message when growth message page rendering fails
  ///
  /// In en, this message translates to:
  /// **'Error rendering Growth Message page'**
  String get errorRenderingGrowthMessage;

  /// Error message in the session flow orchestrator page
  ///
  /// In en, this message translates to:
  /// **'Error in SessionFlowPage'**
  String get errorInSessionFlowPage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sr': return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
