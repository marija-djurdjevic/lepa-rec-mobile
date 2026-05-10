class OnboardingDistancedJournalChallengeDto {
  final String id;
  final String content;
  final String followUpQuestion;

  const OnboardingDistancedJournalChallengeDto({
    required this.id,
    required this.content,
    required this.followUpQuestion,
  });

  factory OnboardingDistancedJournalChallengeDto.fromJson(Map<String, dynamic> json) {
    return OnboardingDistancedJournalChallengeDto(
      id: (json['id'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      followUpQuestion: (json['followUpQuestion'] as String?) ?? '',
    );
  }
}
