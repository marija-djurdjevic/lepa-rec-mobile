class StartDistancedJournalExerciseDto {
  final String challengeId;

  StartDistancedJournalExerciseDto({
    required this.challengeId,
  });

  Map<String, dynamic> toJson() => {
        'challengeId': challengeId,
      };

  @override
  String toString() =>
      'StartDistancedJournalExerciseDto(challengeId: $challengeId)';
}
