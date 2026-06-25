class SubmitDistancedJournalAnswerDto {
  final String exerciseId;

  /// Informational only; the backend ignores this field.
  final DateTime sessionDate;
  final String mainAnswer;
  final String followUpAnswer;
  final String? reflection;
  final String? language;

  SubmitDistancedJournalAnswerDto({
    required this.exerciseId,
    required this.sessionDate,
    required this.mainAnswer,
    required this.followUpAnswer,
    this.reflection,
    this.language,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'sessionDate': sessionDate.toIso8601String(),
    'mainAnswer': mainAnswer,
    'followUpAnswer': followUpAnswer,
    'reflection': reflection,
    if (language != null) 'language': language,
  };

  @override
  String toString() =>
      'SubmitDistancedJournalAnswerDto(exerciseId: $exerciseId, '
      'mainAnswer: ${mainAnswer.length} chars, '
      'followUpAnswer: ${followUpAnswer.length} chars)';
}
