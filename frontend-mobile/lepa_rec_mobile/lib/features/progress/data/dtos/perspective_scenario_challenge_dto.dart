import '../../../sessions/data/dtos/perspective_scenario_question_dto.dart';

class PerspectiveScenarioChallengeDto {
  final String id;
  final String scenarioText;
  final List<PerspectiveScenarioQuestionDto> questions;

  PerspectiveScenarioChallengeDto({
    required this.id,
    required this.scenarioText,
    required this.questions,
  });

  factory PerspectiveScenarioChallengeDto.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    final questions = questionsJson
        .map(
          (item) => PerspectiveScenarioQuestionDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return PerspectiveScenarioChallengeDto(
      id: _toString(json['id']) ?? '',
      scenarioText: json['scenarioText'] as String? ?? '',
      questions: questions,
    );
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }
}
