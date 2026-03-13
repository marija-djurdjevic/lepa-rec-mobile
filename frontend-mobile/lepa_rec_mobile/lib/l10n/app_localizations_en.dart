// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lepa reč';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome';

  @override
  String get primerWelcomeTitle => 'Welcome to Your Breathing Journey';

  @override
  String get primerWelcomeDescription => 'Find a quiet place where you can be present with yourself. This is your time.';

  @override
  String get proceed => 'Proceed';

  @override
  String get breathingExercise => 'Breathing Exercise';

  @override
  String get breathIn => 'Breathe In';

  @override
  String get breathOut => 'Breathe Out';

  @override
  String breatheInForSeconds(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'Breathe in for $secondsString seconds';
  }

  @override
  String breatheOutForSeconds(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'Breathe out for $secondsString seconds';
  }

  @override
  String get holdYourBreath => 'Hold your breath';

  @override
  String get rounds => 'Rounds';

  @override
  String get complete => 'Complete';

  @override
  String get sessionComplete => 'Great job!';

  @override
  String get sessionCompleteMessage => 'You have completed your breathing exercise. You are doing amazing!';

  @override
  String get continueToNext => 'Continue';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get loadingSession => 'Loading...';

  @override
  String get valueStatementTitle => 'What matters most to you?';

  @override
  String get growthMessageTitle => 'Your Growth Message';

  @override
  String get completePrimer => 'Complete Primer';

  @override
  String get errorLoadingStatements => 'Error Loading Statements';

  @override
  String get failedLoadValueStatements => 'Failed to load value statements';

  @override
  String get errorLoadingMessage => 'Error Loading Message';

  @override
  String get failedLoadGrowthMessage => 'Failed to load growth message';

  @override
  String get retry => 'Retry';

  @override
  String get errorRenderingGrowthMessage => 'Error rendering Growth Message page';

  @override
  String get errorInSessionFlowPage => 'Error in SessionFlowPage';

  @override
  String get distancedJournal => 'Distanced Journal';

  @override
  String get yourAnswer => 'Your Answer';

  @override
  String get followUpAnswer => 'Follow-up Answer';

  @override
  String get answerRequired => 'This field is required';

  @override
  String get submit => 'Submit';

  @override
  String get errorLoadingPlan => 'Error Loading Today\'s Plan';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get noTasksToday => 'No Tasks Today';

  @override
  String get completedAllTasks => 'Great job! You\'ve completed all available tasks.';

  @override
  String get todaysPractice => 'Today\'s Practice';

  @override
  String tasksToComplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tasks',
      one: 'task',
    );
    return '$_temp0 to complete';
  }

  @override
  String get yourTasks => 'Your Tasks';

  @override
  String get reflection => 'Reflection';

  @override
  String get perspectiveScenario => 'Perspective Scenario';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get chooseJournalChallenge => 'Choose one journal challenge for today';

  @override
  String get selectAvailablePrompts => 'Select one of the available prompts that resonates with you. The difficulty levels help you find the right challenge.';

  @override
  String get journalCompletedToday => 'Journal completed for today';

  @override
  String get reflectionCompletedToday => 'Reflection completed for today';

  @override
  String get scenarioCompletedToday => 'Scenario completed for today';

  @override
  String get exerciseNotInitialized => 'Error: Exercise not initialized';

  @override
  String get responseSubmittedSuccessfully => 'Response submitted successfully!';

  @override
  String errorSubmittingResponse(String error) {
    return 'Error submitting response: $error';
  }

  @override
  String get shareYourThoughts => 'Share your thoughts...';

  @override
  String get startingExercise => 'Starting exercise...';

  @override
  String get errorStartingExercise => 'Error Starting Exercise';

  @override
  String get loadingPersonalizedMessage => 'Loading your personalized message...';

  @override
  String errorCompletingPrimer(String error) {
    return 'Error completing primer: $error';
  }

  @override
  String get sessionFlowPageError => 'Error in SessionFlowPage';

  @override
  String get reflectionTitle => 'Your Reflection';

  @override
  String get reflectionPrompt => 'Do you have any new insights on this topic?';

  @override
  String get yesterdaysTopic => 'Yesterday\'s Topic';

  @override
  String get yourPreviousAnswer => 'Your Answer';

  @override
  String get previousFollowUpQuestion => 'Follow-up Question';

  @override
  String get yourPreviousFollowUpAnswer => 'Your Follow-up Answer';

  @override
  String get todayReflection => 'Today\'s Reflection';

  @override
  String get reflectionRequired => 'Please share your reflection';

  @override
  String get reflectionSubmittedSuccessfully => 'Reflection submitted successfully!';

  @override
  String errorSubmittingReflection(String error) {
    return 'Error submitting reflection: $error';
  }
}
