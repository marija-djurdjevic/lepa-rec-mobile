import 'package:flutter/material.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/presentation/models/onboarding_perspective_question_args.dart';

class OnboardingPerspectiveScenarioPage extends StatefulWidget {
  const OnboardingPerspectiveScenarioPage({super.key});

  @override
  State<OnboardingPerspectiveScenarioPage> createState() => _OnboardingPerspectiveScenarioPageState();
}

class _OnboardingPerspectiveScenarioPageState extends State<OnboardingPerspectiveScenarioPage> {
  final _remote = OnboardingRemoteDataSource();
  final _local = OnboardingLocalDataSource();

  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    try {
      final isEnglish = Localizations.localeOf(context).languageCode == 'en';
      final lang = isEnglish ? 'en' : 'sr';
      final sessionId = await _local.readSessionId();
      if (sessionId == null || sessionId.isEmpty) throw Exception('Missing onboarding session id');

      final challenge = await _remote.getPerspectiveScenarioChallenge(
        onboardingSessionId: sessionId,
        lang: lang,
      );

      final exercise = await _remote.startPerspectiveScenario(
        onboardingSessionId: sessionId,
        challengeId: challenge.id,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        '/onboarding/perspective-scenario/question',
        arguments: OnboardingPerspectiveQuestionArgs(
          onboardingSessionId: sessionId,
          exerciseId: exercise.id,
          challenge: challenge,
          questionIndex: 0,
          answersByQuestionId: const {},
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.unknownError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Text(_error!),
      ),
    );
  }
}
