class PerspectiveScenarioQuestionDto {
  final String id;
  final String skillId;
  final String questionText;

  PerspectiveScenarioQuestionDto({
    required this.id,
    required this.skillId,
    required this.questionText,
  });

  factory PerspectiveScenarioQuestionDto.fromJson(Map<String, dynamic> json) {
    return PerspectiveScenarioQuestionDto(
      id: _toString(json['id']) ?? '',
      skillId: _toString(json['skillId']) ?? '',
      questionText: json['questionText'] as String? ?? '',
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
    'skillId': skillId,
    'questionText': questionText,
  };
}
