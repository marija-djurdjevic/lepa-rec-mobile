import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lepa_rec_mobile/core/network/api_client.dart';
import 'package:lepa_rec_mobile/l10n/app_localizations.dart';

import 'core/widgets/home_page.dart';
import 'core/widgets/splash_router.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/sessions/presentation/pages/session_flow_page.dart';

void main() {
  debugPrint('🚀 APP START - main() called');
  ApiClient.configure();
  debugPrint('🚀 ApiClient configured');
  runApp(const LepaRecApp());
}

class LepaRecApp extends StatelessWidget {
  const LepaRecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lepa reč',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/': (context) => const SplashRouter(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/session-flow': (context) => SessionFlowPage(
              onSessionComplete: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
              },
            ),
      },
    );
  }
}
