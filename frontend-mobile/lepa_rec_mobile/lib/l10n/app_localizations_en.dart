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
}
