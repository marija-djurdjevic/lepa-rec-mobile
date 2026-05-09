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

  @override
  State<LepaRecApp> createState() => _LepaRecAppState();
}

class _LepaRecAppState extends State<LepaRecApp> {
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

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> appRoutes = {
      '/': (context) => const SplashRouter(),
      '/login': (context) => const LoginPage(),
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

