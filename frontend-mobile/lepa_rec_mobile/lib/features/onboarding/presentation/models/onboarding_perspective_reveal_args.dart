import 'package:lepa_rec_mobile/features/sessions/data/dtos/perspective_scenario_prompt_dto.dart';

class OnboardingPerspectiveRevealArgs {
  final String onboardingSessionId;
  final String exerciseId;
  final PerspectiveScenarioPromptDto challenge;
  final int questionIndex;
  final String revealText;
  final bool isExerciseCompleted;
  final Map<String, String> answersByQuestionId;

  const OnboardingPerspectiveRevealArgs({
    required this.onboardingSessionId,
    required this.exerciseId,
    required this.challenge,
    required this.questionIndex,
    required this.revealText,
    required this.isExerciseCompleted,
    required this.answersByQuestionId,
  });
}
