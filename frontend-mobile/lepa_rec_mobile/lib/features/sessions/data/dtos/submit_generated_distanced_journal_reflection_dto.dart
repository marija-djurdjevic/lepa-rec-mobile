class SubmitGeneratedDistancedJournalReflectionDto {
  final String exerciseId;
  final String answer;

  SubmitGeneratedDistancedJournalReflectionDto({
    required this.exerciseId,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {'exerciseId': exerciseId, 'answer': answer};
}
