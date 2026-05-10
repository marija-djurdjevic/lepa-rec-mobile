import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/features/onboarding/presentation/models/onboarding_perspective_question_args.dart';
import 'package:lepa_rec_mobile/features/onboarding/presentation/models/onboarding_perspective_reveal_args.dart';

class OnboardingPerspectiveRevealPage extends StatefulWidget {
  const OnboardingPerspectiveRevealPage({super.key});

  @override
  State<OnboardingPerspectiveRevealPage> createState() => _OnboardingPerspectiveRevealPageState();
}

class _OnboardingPerspectiveRevealPageState extends State<OnboardingPerspectiveRevealPage> {
  Future<void> _continue(OnboardingPerspectiveRevealArgs args, bool isEnglish) async {
    if (args.isExerciseCompleted) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/onboarding/register', (route) => false);
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      '/onboarding/perspective-scenario/question',
      arguments: OnboardingPerspectiveQuestionArgs(
        onboardingSessionId: args.onboardingSessionId,
        exerciseId: args.exerciseId,
        challenge: args.challenge,
        questionIndex: args.questionIndex + 1,
        answersByQuestionId: args.answersByQuestionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! OnboardingPerspectiveRevealArgs) {
      return Scaffold(body: Center(child: Text(context.l10n.unknownError)));
    }

    final question = args.challenge.questions[args.questionIndex];
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _continue(args, isEnglish),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9B6E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(
              args.isExerciseCompleted
                  ? (isEnglish ? 'Conclude' : 'Zaključi')
                  : (isEnglish ? 'Next question' : 'Sledeće pitanje'),
              style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl + AppSpacing.lg),
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
                  Text(
                    question.questionText,
                    style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF4E6650), height: 1.35),
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
                      args.revealText,
                      style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF5A705B), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
