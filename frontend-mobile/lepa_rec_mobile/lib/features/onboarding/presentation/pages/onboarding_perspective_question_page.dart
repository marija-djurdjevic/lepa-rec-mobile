import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/presentation/models/onboarding_perspective_question_args.dart';
import 'package:lepa_rec_mobile/features/onboarding/presentation/models/onboarding_perspective_reveal_args.dart';

class OnboardingPerspectiveQuestionPage extends StatefulWidget {
  const OnboardingPerspectiveQuestionPage({super.key});

  @override
  State<OnboardingPerspectiveQuestionPage> createState() => _OnboardingPerspectiveQuestionPageState();
}

class _OnboardingPerspectiveQuestionPageState extends State<OnboardingPerspectiveQuestionPage> {
  final _remote = OnboardingRemoteDataSource();
  final _controller = TextEditingController();

  bool _submitting = false;
  String? _error;

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(OnboardingPerspectiveQuestionArgs args) async {
    final answer = _controller.text.trim();
    if (answer.isEmpty) {
      setState(() => _error = context.l10n.answerRequired);
      return;
    }

    final question = args.challenge.questions[args.questionIndex];

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final lang = _isEnglish ? 'en' : 'sr';
      final res = await _remote.answerPerspectiveAndReveal(
        onboardingSessionId: args.onboardingSessionId,
        exerciseId: args.exerciseId,
        questionId: question.id,
        answerText: answer,
        lang: lang,
      );

      if (!mounted) return;
      final allAnswers = Map<String, String>.from(args.answersByQuestionId);
      allAnswers[question.id] = answer;
      Navigator.of(context).pushReplacementNamed(
        '/onboarding/perspective-scenario/reveal',
        arguments: OnboardingPerspectiveRevealArgs(
          onboardingSessionId: args.onboardingSessionId,
          exerciseId: args.exerciseId,
          challenge: args.challenge,
          questionIndex: args.questionIndex,
          revealText: res.reveal,
          isExerciseCompleted: res.isExerciseCompleted,
          answersByQuestionId: allAnswers,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _isEnglish
            ? 'Could not fetch reveal. Please try again.'
            : 'Nismo uspjeli da dobijemo otkrivanje. Pokušajte ponovo.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! OnboardingPerspectiveQuestionArgs) {
      return Scaffold(body: Center(child: Text(context.l10n.unknownError)));
    }

    final question = args.challenge.questions[args.questionIndex];

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: AppSpacing.md),
            ],
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : () => _submit(args),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  _isEnglish ? 'Wrap up' : 'Zaokruži',
                  style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl + AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.perspectiveScenario,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(fontSize: 30, fontWeight: FontWeight.w700, color: const Color(0xFF6B9B6E)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F2E3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))],
                    ),
                    child: Text(
                      args.challenge.scenarioText,
                      style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF4E6650), height: 1.35),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    child: Text(
                      question.questionText,
                      key: ValueKey<String>('q-${question.id}'),
                      style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF4E6650), height: 1.35),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _controller,
                    minLines: 8,
                    maxLines: 14,
                    enabled: !_submitting,
                    decoration: InputDecoration(
                      hintText: context.l10n.shareYourThoughts,
                      filled: true,
                      fillColor: const Color(0xFFFAFCF9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_submitting)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
