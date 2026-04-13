import 'perspective_scenario_answer_dto.dart';

class PerspectiveScenarioExerciseDto {
  final String id;
  final String userId;
  final String challengeId;
  final List<PerspectiveScenarioAnswerDto> answers;
  final DateTime? submittedAt;
  final bool isCompleted;

  PerspectiveScenarioExerciseDto({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.answers,
    this.submittedAt,
    required this.isCompleted,
  });

  factory PerspectiveScenarioExerciseDto.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List<dynamic>? ?? [];

    return PerspectiveScenarioExerciseDto(
      id: _toString(json['id']) ?? '',
      userId: _toString(json['userId']) ?? '',
      challengeId: _toString(json['challengeId']) ?? '',
      answers: answersJson
          .map(
            (item) => PerspectiveScenarioAnswerDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'challengeId': challengeId,
    'answers': answers.map((answer) => answer.toJson()).toList(),
    'submittedAt': submittedAt?.toIso8601String(),
    'isCompleted': isCompleted,
  };
}
