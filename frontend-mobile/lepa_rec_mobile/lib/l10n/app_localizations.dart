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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('sr'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'See Clearly'**
  String get appTitle;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Button label for signing in with Google
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginWithGoogle;

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
  /// **'Peace, practice, growth'**
  String get primerWelcomeTitle;

  /// Description text for the primer welcome screen
  ///
  /// In en, this message translates to:
  /// **'Settle somewhere comfortable where no one will interrupt you. This is your time, you deserve it.'**
  String get primerWelcomeDescription;

  /// Proceed button label
  ///
  /// In en, this message translates to:
  /// **'Begin preparation'**
  String get proceed;

  /// Title for the breathing exercise screen
  ///
  /// In en, this message translates to:
  /// **'Breathing into Calm'**
  String get breathingExercise;

  /// Instruction to breathe in
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get breathIn;

  /// Instruction to breathe out
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get breathOut;

  /// Instruction to pause after exhaling
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseBreathing;

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

  /// Button label to conclude a flow
  ///
  /// In en, this message translates to:
  /// **'Conclude'**
  String get conclude;

  /// Button label to wrap up the perspective scenario
  ///
  /// In en, this message translates to:
  /// **'Wrap up'**
  String get wrapUp;

  /// Home page label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Dashboard page label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Challenge'**
  String get dashboard;

  /// Loading indicator text for session data
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingSession;

  /// Title for the value statement selection screen
  ///
  /// In en, this message translates to:
  /// **'What resonates with you most today?'**
  String get valueStatementTitle;

  /// Title for the growth message screen
  ///
  /// In en, this message translates to:
  /// **'Message for You'**
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
  /// **'Seeing Yourself'**
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

  /// Message shown when the user exceeds the photo upload limit
  ///
  /// In en, this message translates to:
  /// **'You can add up to 3 photos.'**
  String get photoLimitMessage;

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
  /// **'Today\'s Challenge'**
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
  /// **'Journal Review'**
  String get reflection;

  /// Helper text shown on the reflection card before starting the task
  ///
  /// In en, this message translates to:
  /// **'Review your journal entries with fresh eyes.'**
  String get reflectionFreshEyes;

  /// Label for perspective scenario exercise
  ///
  /// In en, this message translates to:
  /// **'Seeing Others'**
  String get perspectiveScenario;

  /// Label shown above the perspective scenario text
  ///
  /// In en, this message translates to:
  /// **'Scenario'**
  String get perspectiveScenarioPromptLabel;

  /// Label for easy difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get levelEasy;

  /// Label for medium difficulty level
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get levelMedium;

  /// Label for hard difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get levelHard;

  /// Helper text for the perspective scenario questionnaire
  ///
  /// In en, this message translates to:
  /// **'Answer each question before you reveal the final perspective.'**
  String get answerEachScenarioQuestion;

  /// Disclaimer shown under scenario text to explain task goal
  ///
  /// In en, this message translates to:
  /// **'We will ask you questions about the shown scene. The goal is not to guess every exact detail in the background of the story, but to get as close as possible to understanding other people\'s perspectives, needs, and wishes that shaped their reactions and emotions. Every thoughtful answer is good, even when it differs in details from the background story we will reveal at the end.'**
  String get perspectiveScenarioDisclaimer;

  /// First short line in perspective scenario disclaimer
  ///
  /// In en, this message translates to:
  /// **'We will ask you questions about the shown scene.'**
  String get perspectiveDisclaimerWhatWeDo;

  /// Second short line in perspective scenario disclaimer
  ///
  /// In en, this message translates to:
  /// **'The goal is not to guess every exact detail in the background story.'**
  String get perspectiveDisclaimerNotGoal;

  /// Third short line in perspective scenario disclaimer
  ///
  /// In en, this message translates to:
  /// **'The goal is to understand people’s perspectives, needs, and wishes that shape their reactions and emotions.'**
  String get perspectiveDisclaimerGoal;

  /// Fourth short line in perspective scenario disclaimer
  ///
  /// In en, this message translates to:
  /// **'Every thoughtful answer is good, even when it differs from the background story we reveal at the end.'**
  String get perspectiveDisclaimerAnswerGood;

  /// Action label to expand additional content
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// Action label to collapse additional content
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// Label for a numbered perspective scenario question
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String scenarioQuestionNumber(int number);

  /// Title for the perspective scenario reveal screen
  ///
  /// In en, this message translates to:
  /// **'Whatâ€™s Behind the Scenes?'**
  String get perspectiveRevealTitle;

  /// Helper text shown below the reveal content
  ///
  /// In en, this message translates to:
  /// **'Reflect on your answers and the assumptions you made.'**
  String get perspectiveRevealHint;

  /// Subtitle for the perspective scenario reveal screen
  ///
  /// In en, this message translates to:
  /// **'Here is the revealed perspective from this scenario.'**
  String get perspectiveRevealSubtitle;

  /// Title shown when a perspective scenario answer needs guidance
  ///
  /// In en, this message translates to:
  /// **'Let\'s look at it from another angle.'**
  String get perspectiveGuideTitle;

  /// Intro text shown above a Socratic guide question
  ///
  /// In en, this message translates to:
  /// **'Consider this question, then try again.'**
  String get perspectiveGuideIntro;

  /// Label above the retry answer input after guidance
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get perspectiveTryAgainLabel;

  /// Generic learner-facing error when perspective scenario answer submission fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get perspectiveScenarioSubmitGenericError;

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
  /// **'Journal review completed for today'**
  String get reflectionCompletedToday;

  /// Message indicating perspective scenario is completed for the day
  ///
  /// In en, this message translates to:
  /// **'Scenario completed for today'**
  String get scenarioCompletedToday;

  /// Reward message shown on the dashboard after all daily tasks are completed
  ///
  /// In en, this message translates to:
  /// **'You completed today\'s challenge! Join us tomorrow for the next one.'**
  String get dailyChallengeReward;

  /// Error message when exercise fails to initialize
  ///
  /// In en, this message translates to:
  /// **'Error: Exercise not initialized'**
  String get exerciseNotInitialized;

  /// Shown when an exercise is missing or the user does not own it
  ///
  /// In en, this message translates to:
  /// **'This exercise isn\'t available or doesn\'t belong to you.'**
  String get exerciseNotFoundOrOwned;

  /// Shown when primer completion is missing required data
  ///
  /// In en, this message translates to:
  /// **'Missing required primer data. Please restart the session.'**
  String get missingPrimerData;

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
  /// **'Journal Review'**
  String get reflectionTitle;

  /// Main prompt for the reflection exercise
  ///
  /// In en, this message translates to:
  /// **'Do you have any new insights on this topic?'**
  String get reflectionPrompt;

  /// Guidance text shown before yesterday's prompt and answers
  ///
  /// In en, this message translates to:
  /// **'Revisit your journal entry with fresh eyes.'**
  String get reflectionGuidance;

  /// Main question prompting the new reflection
  ///
  /// In en, this message translates to:
  /// **'How do you feel about what you wrote? What are the new insights?'**
  String get reflectionFreshQuestion;

  /// Label shown before a later reflection entry in history
  ///
  /// In en, this message translates to:
  /// **'After some time, you reflected like this:'**
  String get reflectionAfterTimeLabel;

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
  /// **'Today\'s Journal Review'**
  String get todayReflection;

  /// Helper text for distanced journal prompt
  ///
  /// In en, this message translates to:
  /// **'Use â€œheâ€, â€œsheâ€, or your name instead of â€œIâ€.'**
  String get distancedJournalHint;

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
  /// **'Tap to begin the exercise'**
  String get startBreathing;

  /// Instruction shown before the breathing exercise starts
  ///
  /// In en, this message translates to:
  /// **'Begin when ready'**
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
  /// **'History'**
  String get progress;

  /// Profile page label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Profile label for choosing application language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option label
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Serbian language option label
  ///
  /// In en, this message translates to:
  /// **'Serbian'**
  String get languageSerbian;

  /// Hint on profile page that language change applies after save
  ///
  /// In en, this message translates to:
  /// **'Language change is applied after you save changes.'**
  String get profileLanguageSaveHint;

  /// Title for daily session flow
  ///
  /// In en, this message translates to:
  /// **'Daily Practice'**
  String get dailySession;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// First onboarding message - hook
  ///
  /// In en, this message translates to:
  /// **'You have probably noticed how often people misunderstand each other.\n\nA daughter argues with her mother. We gossip about and reject colleagues. Political opponents do not even talk.\n\nDoes it have to be that way?'**
  String get onboardingStoryHook;

  /// Second onboarding message - skill explanation
  ///
  /// In en, this message translates to:
  /// **'It does not.\n\nWe can understand others and help them understand us. But this is a skill we train like a muscle.\n\nResearch shows that people who practice these abilities resolve conflicts more easily and feel more connected to their people.'**
  String get onboardingStorySkill;

  /// Third onboarding message - daily habit
  ///
  /// In en, this message translates to:
  /// **'Ten minutes a day.\n\nSometimes a short scenario where you practice understanding what someone else thinks and feels. Sometimes a reflection on your own day from the position of a wise observer.\n\nA small habit that gradually changes how you see people and how they see you.'**
  String get onboardingStoryHabit;

  /// Button to return to the previous onboarding story message
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingStoryBack;

  /// Button to advance in onboarding story flow
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingStoryContinue;

  /// Title for onboarding language selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get onboardingChooseLanguageTitle;

  /// Title for about app section on profile page
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get aboutApp;

  /// Item in About app section that opens onboarding story
  ///
  /// In en, this message translates to:
  /// **'Intro story'**
  String get onboardingStoryReferenceButton;

  /// Title of screen that shows all onboarding story messages together
  ///
  /// In en, this message translates to:
  /// **'Onboarding story'**
  String get onboardingStoryReferenceTitle;

  /// Short intro text above onboarding story article sections
  ///
  /// In en, this message translates to:
  /// **'This is the intro story shown to users during their first app experience.'**
  String get onboardingStoryReferenceIntro;

  /// Section heading in onboarding story article
  ///
  /// In en, this message translates to:
  /// **'Message {number}'**
  String onboardingStorySectionTitle(int number);

  /// Small label shown above onboarding hook choice title
  ///
  /// In en, this message translates to:
  /// **'FIRST STEP'**
  String get onboardingLabel;

  /// Question for selecting the initial onboarding exercise
  ///
  /// In en, this message translates to:
  /// **'Now, let us try one exercise like that. Would you rather look at someone else\'s situation, or look at your own from someone else\'s perspective?'**
  String get onboardingHookChoiceTitle;

  /// Option title for distanced journal onboarding choice
  ///
  /// In en, this message translates to:
  /// **'Look at my own situation from another perspective'**
  String get onboardingHookChoiceSelfTitle;

  /// Option title for perspective scenario onboarding choice
  ///
  /// In en, this message translates to:
  /// **'Look at someone else\'s situation'**
  String get onboardingHookChoiceOthersTitle;

  /// Description for the seeing-yourself onboarding exercise
  ///
  /// In en, this message translates to:
  /// **'Write about your own situation as a wise observer. This helps you step back and see yourself and your choices more clearly.'**
  String get onboardingDistancedJournalDescription;

  /// Description for the seeing-others onboarding exercise
  ///
  /// In en, this message translates to:
  /// **'Go through a short scenario and try to understand what the other person thinks and feels.'**
  String get onboardingPerspectiveScenarioDescription;

  /// Title for the profile delete account section
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountTitle;

  /// Helper text with link for account deletion info page
  ///
  /// In en, this message translates to:
  /// **'Learn more: https://api.sagledaj.com/account-deletion'**
  String get profileDeleteAccountLearnMore;

  /// Delete account action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteAccountAction;

  /// Cancel label in account deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileDeleteAccountCancel;

  /// Title of account deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get profileDeleteAccountConfirmTitle;

  /// Message of account deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your Sagledaj account and sign you out. This action cannot be undone.'**
  String get profileDeleteAccountConfirmMessage;

  /// Snackbar shown when account is deleted
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get profileDeleteAccountSuccess;

  /// Snackbar shown when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Could not delete account right now. Please try again.'**
  String get profileDeleteAccountError;

  /// Snackbar shown when learn more link cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open link.'**
  String get profileDeleteAccountInfoOpenFailed;
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
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
