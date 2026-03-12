import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/auth_session_reader.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/sessions/data/repositories/session_repository.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    debugPrint('🎬 SPLASH_ROUTER initState - navigation decision starting');
    _route();
  }

  Future<void> _route() async {
    debugPrint('🎬 SPLASH_ROUTER._route() - checking session...');
    final hasSession = await AuthSessionReader().hasSession();
    debugPrint('🎬 SPLASH_ROUTER - hasSession: $hasSession');

    if (!mounted) return;

    if (!hasSession) {
      debugPrint('🎬 SPLASH_ROUTER - No session found, navigating to /login');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      return;
    }

    debugPrint('🎬 SPLASH_ROUTER - Session exists, fetching today session from API...');
    try {
      final sessionRepo = SessionRepository();
      final sessionState = await sessionRepo.getTodaySession();

      if (!mounted) return;

      debugPrint('🎬 SPLASH_ROUTER - Session fetched, primerCompleted: ${sessionState.primerCompleted}');
      final route =
          sessionState.primerCompleted ? '/home' : '/session-flow';
      debugPrint('🎬 SPLASH_ROUTER - Navigating to: $route');

      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
    } on DioException catch (e) {
      if (!mounted) return;

      debugPrint('🎬 SPLASH_ROUTER - DioException: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 404) {
        debugPrint('🎬 SPLASH_ROUTER - 404 No session on server, navigating to /session-flow');
        Navigator.of(context).pushNamedAndRemoveUntil('/session-flow', (_) => false);
        return;
      }

      if (e.response?.statusCode == 401) {
        debugPrint('🎬 SPLASH_ROUTER - 401 Unauthorized, clearing session and navigating to /login');
        await AuthLocalDataSource().clearSession();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        return;
      }

      debugPrint('🎬 SPLASH_ROUTER - API error, navigating to /login');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
      debugPrint('🎬 SPLASH_ROUTER - Unexpected error: $e');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
