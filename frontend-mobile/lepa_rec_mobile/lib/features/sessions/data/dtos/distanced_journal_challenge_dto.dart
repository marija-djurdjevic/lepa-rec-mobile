class DistancedJournalChallengeDto {
  final String id;
  final String? skillId;
  final String content;
  final String followUpQuestion;
  final String challengeLevel;

  DistancedJournalChallengeDto({
    required this.id,
    this.skillId,
    required this.content,
    required this.followUpQuestion,
    required this.challengeLevel,
  });

  factory DistancedJournalChallengeDto.fromJson(Map<String, dynamic> json) {
    return DistancedJournalChallengeDto(
      id: _toString(json['id']) ?? '',
      skillId: _toString(json['skillId']),
      content: json['content'] as String? ?? '',
      followUpQuestion: json['followUpQuestion'] as String? ?? '',
      challengeLevel: _mapChallengeLevel(json['challengeLevel']),
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
    'skillId': skillId,
    'content': content,
    'followUpQuestion': followUpQuestion,
    'challengeLevel': challengeLevel,
  };

  @override
  String toString() =>
      'DistancedJournalChallengeDto(id: $id, content: $content, '
      'challengeLevel: $challengeLevel)';
}
