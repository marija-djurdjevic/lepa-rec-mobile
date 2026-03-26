import 'perspective_scenario_question_dto.dart';

class PerspectiveScenarioPromptDto {
  final String id;
  final String scenarioText;
  final String challengeLevel;
  final List<PerspectiveScenarioQuestionDto> questions;

  PerspectiveScenarioPromptDto({
    required this.id,
    required this.scenarioText,
    required this.challengeLevel,
    required this.questions,
  });

  factory PerspectiveScenarioPromptDto.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];

    return PerspectiveScenarioPromptDto(
      id: _toString(json['id']) ?? '',
      scenarioText: json['scenarioText'] as String? ?? '',
      challengeLevel: _mapChallengeLevel(json['challengeLevel']),
      questions: questionsJson
          .map(
            (item) => PerspectiveScenarioQuestionDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  static String _mapChallengeLevel(dynamic value) {
    switch (value) {
      case 0:
        return 'Easy';
      case 1:
        return 'Medium';
      case 2:
        return 'Hard';
      default:
        return value.toString();
    }
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'scenarioText': scenarioText,
    'challengeLevel': challengeLevel,
    'questions': questions.map((question) => question.toJson()).toList(),
  };
}
