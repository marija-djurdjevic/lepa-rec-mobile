class SubmitDistancedJournalAnswerDto {
  final String exerciseId;
  final DateTime sessionDate;
  final String mainAnswer;
  final String followUpAnswer;
  final String? reflection;

  SubmitDistancedJournalAnswerDto({
    required this.exerciseId,
    required this.sessionDate,
    required this.mainAnswer,
    required this.followUpAnswer,
    this.reflection,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'sessionDate': sessionDate.toIso8601String(),
        'mainAnswer': mainAnswer,
        'followUpAnswer': followUpAnswer,
        'reflection': reflection,
      };

  @override
  String toString() =>
      'SubmitDistancedJournalAnswerDto(exerciseId: $exerciseId, '
      'mainAnswer: ${mainAnswer.length} chars, '
      'followUpAnswer: ${followUpAnswer.length} chars)';
}
