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

  /// Title for the distanced journal exercise screen
  ///
  /// In en, this message translates to:
  /// **'Distanced Journal'**
  String get distancedJournal;

  /// Label for the main answer text field in distanced journal
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// Label for the follow-up answer text field in distanced journal
  ///
  /// In en, this message translates to:
  /// **'Follow-up Answer'**
  String get followUpAnswer;

  /// Validation error message when an answer field is empty
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get answerRequired;

  /// Submit button label for distanced journal
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Error title when today's practice plan fails to load
  ///
  /// In en, this message translates to:
  /// **'Error Loading Today\'s Plan'**
  String get errorLoadingPlan;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Message when there are no tasks to complete today
  ///
  /// In en, this message translates to:
  /// **'No Tasks Today'**
  String get noTasksToday;

  /// Congratulatory message when all tasks are completed
  ///
  /// In en, this message translates to:
  /// **'Great job! You\'ve completed all available tasks.'**
  String get completedAllTasks;

  /// Header for today's practice tasks
  ///
  /// In en, this message translates to:
  /// **'Today\'s Practice'**
  String get todaysPractice;

  /// Label showing number of tasks to complete
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{task} other{tasks}} to complete'**
  String tasksToComplete(int count);

  /// Section header for task list
  ///
  /// In en, this message translates to:
  /// **'Your Tasks'**
  String get yourTasks;

  /// Label for reflection exercise
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflection;

  /// Label for perspective scenario exercise
  ///
  /// In en, this message translates to:
  /// **'Perspective Scenario'**
  String get perspectiveScenario;

  /// Label shown above the perspective scenario text
  ///
  /// In en, this message translates to:
  /// **'Scenario'**
  String get perspectiveScenarioPromptLabel;

  /// Helper text for the perspective scenario questionnaire
  ///
  /// In en, this message translates to:
  /// **'Answer each question before you reveal the final perspective.'**
  String get answerEachScenarioQuestion;

  /// Label for a numbered perspective scenario question
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String scenarioQuestionNumber(int number);

  /// Title for the perspective scenario reveal screen
  ///
  /// In en, this message translates to:
  /// **'Perspective Reveal'**
  String get perspectiveRevealTitle;

  /// Subtitle for the perspective scenario reveal screen
  ///
  /// In en, this message translates to:
  /// **'Here is the revealed perspective from this scenario.'**
  String get perspectiveRevealSubtitle;

  /// Error message when submitting a perspective scenario fails
  ///
  /// In en, this message translates to:
  /// **'Error submitting perspective scenario: {error}'**
  String errorSubmittingPerspectiveScenario(String error);

  /// Text indicating a feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Instruction to select a journal challenge
  ///
  /// In en, this message translates to:
  /// **'Choose one journal challenge for today'**
  String get chooseJournalChallenge;

  /// Helper text explaining how to choose a journal challenge
  ///
  /// In en, this message translates to:
  /// **'Select one of the available prompts that resonates with you. The difficulty levels help you find the right challenge.'**
  String get selectAvailablePrompts;

  /// Message indicating distanced journal is completed for the day
  ///
  /// In en, this message translates to:
  /// **'Journal completed for today'**
  String get journalCompletedToday;

  /// Message indicating reflection is completed for the day
  ///
  /// In en, this message translates to:
  /// **'Reflection completed for today'**
  String get reflectionCompletedToday;

  /// Message indicating perspective scenario is completed for the day
  ///
  /// In en, this message translates to:
  /// **'Scenario completed for today'**
  String get scenarioCompletedToday;

  /// Error message when exercise fails to initialize
  ///
  /// In en, this message translates to:
  /// **'Error: Exercise not initialized'**
  String get exerciseNotInitialized;

  /// Success message after submitting distanced journal response
  ///
  /// In en, this message translates to:
  /// **'Response submitted successfully!'**
  String get responseSubmittedSuccessfully;

  /// Error message when submitting distanced journal response fails
  ///
  /// In en, this message translates to:
  /// **'Error submitting response: {error}'**
  String errorSubmittingResponse(String error);

  /// Placeholder text for answer input fields
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts...'**
  String get shareYourThoughts;

  /// Loading message when initializing exercise
  ///
  /// In en, this message translates to:
  /// **'Starting exercise...'**
  String get startingExercise;

  /// Error title when exercise initialization fails
  ///
  /// In en, this message translates to:
  /// **'Error Starting Exercise'**
  String get errorStartingExercise;

  /// Placeholder text while loading growth message
  ///
  /// In en, this message translates to:
  /// **'Loading your personalized message...'**
  String get loadingPersonalizedMessage;

  /// Error message when primer completion fails
  ///
  /// In en, this message translates to:
  /// **'Error completing primer: {error}'**
  String errorCompletingPrimer(String error);

  /// Error title in session flow orchestrator
  ///
  /// In en, this message translates to:
  /// **'Error in SessionFlowPage'**
  String get sessionFlowPageError;

  /// Title for the reflection screen
  ///
  /// In en, this message translates to:
  /// **'Your Reflection'**
  String get reflectionTitle;

  /// Main prompt for the reflection exercise
  ///
  /// In en, this message translates to:
  /// **'Do you have any new insights on this topic?'**
  String get reflectionPrompt;

  /// Label for yesterday's journal topic
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s Topic'**
  String get yesterdaysTopic;

  /// Label for the user's previous main answer
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourPreviousAnswer;

  /// Label for the previous follow-up question
  ///
  /// In en, this message translates to:
  /// **'Follow-up Question'**
  String get previousFollowUpQuestion;

  /// Label for the user's previous follow-up answer
  ///
  /// In en, this message translates to:
  /// **'Your Follow-up Answer'**
  String get yourPreviousFollowUpAnswer;

  /// Label for today's reflection input field
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reflection'**
  String get todayReflection;

  /// Title for the journal feedback screen
  ///
  /// In en, this message translates to:
  /// **'Reflection Feedback'**
  String get journalFeedbackTitle;

  /// Subtitle on the feedback screen
  ///
  /// In en, this message translates to:
  /// **'Here is a gentle reflection on your journaling style'**
  String get journalFeedbackSubtitle;

  /// Button text to continue back to dashboard
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToDashboard;

  /// Feedback shown when distancing was good
  ///
  /// In en, this message translates to:
  /// **'You described the situation with a good sense of distance. This can help you look at the experience more calmly.'**
  String get goodDistancingFeedback;

  /// Feedback shown when distancing is mixed
  ///
  /// In en, this message translates to:
  /// **'You already show some distance in the way you wrote. You can go even further by talking about yourself more from the outside.'**
  String get mixedDistancingFeedback;

  /// Feedback shown when more distancing is needed
  ///
  /// In en, this message translates to:
  /// **'Your response stayed quite close to the immediate experience. Next time, try describing the event more as if you were observing someone from the outside.'**
  String get needsMoreDistancingFeedback;

  /// Validation error message when reflection field is empty
  ///
  /// In en, this message translates to:
  /// **'Please share your reflection'**
  String get reflectionRequired;

  /// Success message after submitting reflection
  ///
  /// In en, this message translates to:
  /// **'Reflection submitted successfully!'**
  String get reflectionSubmittedSuccessfully;

  /// Text shown inside the breathing circle before the exercise starts
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get startBreathing;

  /// Instruction shown before the breathing exercise starts
  ///
  /// In en, this message translates to:
  /// **'Begin when you are ready'**
  String get beginWhenReady;

  /// Text shown during the short countdown before the breathing exercise starts
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get getReady;

  /// Error message when reflection submission fails
  ///
  /// In en, this message translates to:
  /// **'Error submitting reflection: {error}'**
  String errorSubmittingReflection(String error);

  /// Progress page label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Profile page label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Title for daily session flow
  ///
  /// In en, this message translates to:
  /// **'Daily Session'**
  String get dailySession;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
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
