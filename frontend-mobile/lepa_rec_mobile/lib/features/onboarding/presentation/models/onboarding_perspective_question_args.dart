import 'package:lepa_rec_mobile/features/sessions/data/dtos/perspective_scenario_prompt_dto.dart';

class OnboardingPerspectiveQuestionArgs {
  final String onboardingSessionId;
  final String exerciseId;
  final PerspectiveScenarioPromptDto challenge;
  final int questionIndex;
  final Map<String, String> answersByQuestionId;

  const OnboardingPerspectiveQuestionArgs({
    required this.onboardingSessionId,
    required this.exerciseId,
    required this.challenge,
    required this.questionIndex,
    required this.answersByQuestionId,
  });
}
