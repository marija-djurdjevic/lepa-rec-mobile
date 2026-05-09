class PerspectiveScenarioQuestionDto {
  final String id;
  final String skillId;
  final int order;
  final String questionText;
  final String? reveal;

  PerspectiveScenarioQuestionDto({
    required this.id,
    required this.skillId,
    required this.order,
    required this.questionText,
    this.reveal,
  });

  factory PerspectiveScenarioQuestionDto.fromJson(Map<String, dynamic> json) {
    return PerspectiveScenarioQuestionDto(
      id: _toString(json['id']) ?? '',
      skillId: _toString(json['skillId']) ?? '',
      order: _toInt(json['order']) ?? 0,
      questionText: json['questionText'] as String? ?? '',
      reveal:
          json['reveal'] as String? ??
          json['revealText'] as String? ??
          json['Reveal'] as String? ??
          json['text'] as String?,
    );
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'skillId': skillId,
    'order': order,
    'questionText': questionText,
    'reveal': reveal,
  };
}
