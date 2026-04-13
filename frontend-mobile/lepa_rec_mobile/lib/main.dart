import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lepa_rec_mobile/core/network/api_client.dart';
import 'package:lepa_rec_mobile/l10n/app_localizations.dart';

import 'app/home_page.dart';
import 'app/splash_router.dart';
import 'core/navigation/app_page_route.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/sessions/presentation/pages/session_flow_page.dart';

void main() {
  ApiClient.configure();
  runApp(const LepaRecApp());
}

class LepaRecApp extends StatelessWidget {
  const LepaRecApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> appRoutes = {
      '/': (context) => const SplashRouter(),
      '/login': (context) => const LoginPage(),
      '/home': (context) => const HomePage(),
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

