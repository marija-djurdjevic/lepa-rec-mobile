class DistancedJournalExerciseDto {
  final String id;
  final String userId;
  final String challengeId;
  final String? mainAnswer;
  final String? followUpAnswer;
  final String? reflection;
  final DateTime? submittedAt;
  final bool isCompleted;

  DistancedJournalExerciseDto({
    required this.id,
    required this.userId,
    required this.challengeId,
    this.mainAnswer,
    this.followUpAnswer,
    this.reflection,
    this.submittedAt,
    required this.isCompleted,
  });

  factory DistancedJournalExerciseDto.fromJson(Map<String, dynamic> json) {
    return DistancedJournalExerciseDto(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      challengeId: json['challengeId'] as String? ?? '',
      mainAnswer: json['mainAnswer'] as String?,
      followUpAnswer: json['followUpAnswer'] as String?,
      reflection: json['reflection'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'challengeId': challengeId,
    'mainAnswer': mainAnswer,
    'followUpAnswer': followUpAnswer,
    'reflection': reflection,
    'submittedAt': submittedAt?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  @override
  String toString() =>
      'DistancedJournalExerciseDto(id: $id, userId: $userId, '
      'challengeId: $challengeId, isCompleted: $isCompleted)';
}
