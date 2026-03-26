class PerspectiveScenarioAnswerDto {
  final String questionId;
  final String answerText;

  PerspectiveScenarioAnswerDto({
    required this.questionId,
    required this.answerText,
  });

  factory PerspectiveScenarioAnswerDto.fromJson(Map<String, dynamic> json) {
    return PerspectiveScenarioAnswerDto(
      questionId: _toString(json['questionId']) ?? '',
      answerText: json['answerText'] as String? ?? '',
    );
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'answerText': answerText,
  };
}
