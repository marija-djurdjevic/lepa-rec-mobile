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
    _route();
  }

  Future<void> _route() async {
    final hasSession = await AuthSessionReader().hasSession();

    if (!mounted) return;

    if (!hasSession) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      return;
    }

    try {
      final sessionRepo = SessionRepository();
      final sessionState = await sessionRepo.getTodaySession();

      if (!mounted) return;

      final route =
          sessionState.primerCompleted ? '/home' : '/session-flow';

      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 404) {
        Navigator.of(context).pushNamedAndRemoveUntil('/session-flow', (_) => false);
        return;
      }

      if (e.response?.statusCode == 401) {
        await AuthLocalDataSource().clearSession();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
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
