import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lepa_rec_mobile/core/network/api_client.dart';
import 'package:lepa_rec_mobile/l10n/app_localizations.dart';

import 'app/home_page.dart';
import 'app/splash_router.dart';
import 'core/navigation/app_page_route.dart';
import 'core/constants/app_theme.dart';
import 'core/localization/app_locale_storage.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/onboarding/presentation/pages/onboarding_distanced_journal_follow_up_page.dart';
import 'features/onboarding/presentation/pages/onboarding_distanced_journal_page.dart';
import 'features/onboarding/presentation/pages/onboarding_perspective_question_page.dart';
import 'features/onboarding/presentation/pages/onboarding_perspective_reveal_page.dart';
import 'features/onboarding/presentation/pages/onboarding_hook_choice_page.dart';
import 'features/onboarding/presentation/pages/onboarding_language_page.dart';
import 'features/onboarding/presentation/pages/onboarding_perspective_scenario_page.dart';
import 'features/onboarding/presentation/pages/onboarding_registration_page.dart';
import 'features/sessions/presentation/pages/session_flow_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.configure();
  final savedLanguageCode = await AppLocaleStorage().readLanguageCode();
  ApiClient.setLanguageCode(savedLanguageCode ?? 'sr');
  runApp(LepaRecApp(initialLanguageCode: savedLanguageCode));
}

class LepaRecApp extends StatefulWidget {
  final String? initialLanguageCode;

  const LepaRecApp({super.key, this.initialLanguageCode});

  static LepaRecAppState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<LepaRecAppState>();
  }

  @override
  State<LepaRecApp> createState() => LepaRecAppState();
}

class LepaRecAppState extends State<LepaRecApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(_normalizeLanguageCode(widget.initialLanguageCode));
  }

  String _normalizeLanguageCode(String? languageCode) {
    return languageCode == 'en' ? 'en' : 'sr';
  }

  Future<void> _changeLanguage(String languageCode) async {
    final normalized = _normalizeLanguageCode(languageCode);
    if (_locale.languageCode == normalized) return;

    setState(() {
      _locale = Locale(normalized);
    });
    ApiClient.setLanguageCode(normalized);

    await AppLocaleStorage().saveLanguageCode(normalized);
  }

  Future<void> changeLanguage(String languageCode) {
    return _changeLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> appRoutes = {
      '/': (context) => const SplashRouter(),
      '/login': (context) => const LoginPage(),
      '/onboarding/language': (context) => const OnboardingLanguagePage(),
      '/onboarding/hook-choice': (context) => const OnboardingHookChoicePage(),
      '/onboarding/distanced-journal': (context) => const OnboardingDistancedJournalPage(),
      '/onboarding/distanced-journal/follow-up': (context) => const OnboardingDistancedJournalFollowUpPage(),
      '/onboarding/perspective-scenario': (context) => const OnboardingPerspectiveScenarioPage(),
      '/onboarding/perspective-scenario/question': (context) => const OnboardingPerspectiveQuestionPage(),
      '/onboarding/perspective-scenario/reveal': (context) => const OnboardingPerspectiveRevealPage(),
      '/onboarding/register': (context) => const OnboardingRegistrationPage(),
      '/home': (context) => HomePage(
            onLanguageChanged: _changeLanguage,
          ),
      '/session-flow': (context) => SessionFlowPage(
            onSessionComplete: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
            },
          ),
    };

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      locale: _locale,
      onGenerateRoute: (settings) {
        final builder = appRoutes[settings.name];
        if (builder == null) {
          return null;
        }
        return AppPageRoute(
          builder: builder,
          settings: settings,
        );
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

