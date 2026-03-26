import 'perspective_scenario_exercise_dto.dart';

class SubmitPerspectiveScenarioResultDto {
  final PerspectiveScenarioExerciseDto exercise;
  final String reveal;

  SubmitPerspectiveScenarioResultDto({
    required this.exercise,
    required this.reveal,
  });

  factory SubmitPerspectiveScenarioResultDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubmitPerspectiveScenarioResultDto(
      exercise: PerspectiveScenarioExerciseDto.fromJson(
        json['exercise'] as Map<String, dynamic>,
      ),
      reveal: json['reveal'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'reveal': reveal,
  };
}
