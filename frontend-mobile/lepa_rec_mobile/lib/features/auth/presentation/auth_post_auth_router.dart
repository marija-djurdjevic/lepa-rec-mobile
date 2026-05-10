import 'package:flutter/material.dart';

import '../../onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../onboarding/data/datasources/onboarding_remote_datasource.dart';
import '../data/dtos/auth_response.dart';

class AuthPostAuthRouter {
  AuthPostAuthRouter._();

  static Future<void> routeAfterAuth(
    BuildContext context,
    AuthResponse auth,
  ) async {
    if (auth.onboardingCompleted) {
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      return;
    }

    // Start anonymous onboarding session for the onboarding UI flow.
    try {
      final remote = OnboardingRemoteDataSource();
      final local = OnboardingLocalDataSource();
      final session = await remote.startSession();
      await local.saveSessionId(session.onboardingSessionId);
    } catch (_) {
      // If session creation fails, onboarding screens will surface a user-facing error.
    }

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding/language', (_) => false);
  }
}

