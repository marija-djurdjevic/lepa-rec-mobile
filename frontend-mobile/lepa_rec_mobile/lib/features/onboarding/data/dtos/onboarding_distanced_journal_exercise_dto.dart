class OnboardingDistancedJournalExerciseDto {
  final String id;
  final String challengeId;

  const OnboardingDistancedJournalExerciseDto({
    required this.id,
    required this.challengeId,
  });

  factory OnboardingDistancedJournalExerciseDto.fromJson(Map<String, dynamic> json) {
    return OnboardingDistancedJournalExerciseDto(
      id: (json['id'] as String?) ?? '',
      challengeId: (json['challengeId'] as String?) ?? '',
    );
  }
}
