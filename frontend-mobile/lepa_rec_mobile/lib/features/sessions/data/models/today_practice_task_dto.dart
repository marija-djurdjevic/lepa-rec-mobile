class DistancedJournalReflectionPromptDto {
  final String exerciseId;
  final String challengeContent;
  final String challengeFollowUpQuestion;
  final String? previousMainAnswer;
  final String? previousFollowUpAnswer;

  DistancedJournalReflectionPromptDto({
    required this.exerciseId,
    required this.challengeContent,
    required this.challengeFollowUpQuestion,
    this.previousMainAnswer,
    this.previousFollowUpAnswer,
  });

  factory DistancedJournalReflectionPromptDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return DistancedJournalReflectionPromptDto(
      exerciseId: _toString(json['exerciseId']) ?? '',
      challengeContent: json['challengeContent'] as String? ?? '',
      challengeFollowUpQuestion:
          json['challengeFollowUpQuestion'] as String? ?? '',
      previousMainAnswer: json['previousMainAnswer'] as String?,
      previousFollowUpAnswer: json['previousFollowUpAnswer'] as String?,
    );
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'challengeContent': challengeContent,
        'challengeFollowUpQuestion': challengeFollowUpQuestion,
        'previousMainAnswer': previousMainAnswer,
        'previousFollowUpAnswer': previousFollowUpAnswer,
      };

  @override
  String toString() =>
      'DistancedJournalReflectionPromptDto(exerciseId: $exerciseId, '
      'challengeContent: $challengeContent)';
}

