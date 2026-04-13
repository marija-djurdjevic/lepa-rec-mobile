import 'perspective_scenario_answer_dto.dart';

class SubmitPerspectiveScenarioAnswerDto {
  final String exerciseId;
  /// Informational only; the backend ignores this field.
  final DateTime sessionDate;
  final List<PerspectiveScenarioAnswerDto> answers;

  SubmitPerspectiveScenarioAnswerDto({
    required this.exerciseId,
    required this.sessionDate,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'sessionDate': sessionDate.toIso8601String(),
    'answers': answers.map((answer) => answer.toJson()).toList(),
  };
}
