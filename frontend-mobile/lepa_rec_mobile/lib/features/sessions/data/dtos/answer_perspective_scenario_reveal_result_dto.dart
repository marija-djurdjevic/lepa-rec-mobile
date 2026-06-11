import 'perspective_scenario_exercise_dto.dart';
import 'submit_perspective_scenario_result_dto.dart';

class AnswerPerspectiveScenarioRevealResultDto {
  final PerspectiveScenarioExerciseDto exercise;
  final PerspectiveScenarioRevealDto? reveal;
  final bool isExerciseCompleted;
  final int answeredQuestionsCount;
  final int totalQuestions;

  AnswerPerspectiveScenarioRevealResultDto({
    required this.exercise,
    required this.reveal,
    required this.isExerciseCompleted,
    required this.answeredQuestionsCount,
    required this.totalQuestions,
  });

  factory AnswerPerspectiveScenarioRevealResultDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AnswerPerspectiveScenarioRevealResultDto(
      exercise: PerspectiveScenarioExerciseDto.fromJson(
        json['exercise'] as Map<String, dynamic>,
      ),
      reveal: json['reveal'] is Map<String, dynamic>
          ? PerspectiveScenarioRevealDto.fromJson(
              json['reveal'] as Map<String, dynamic>,
            )
          : null,
      isExerciseCompleted: json['isExerciseCompleted'] as bool? ?? false,
      answeredQuestionsCount: _toInt(json['answeredQuestionsCount']) ?? 0,
      totalQuestions: _toInt(json['totalQuestions']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

