class SubmitReflectionAnswerDto {
  final String exerciseId;
  /// Informational only; the backend ignores this field.
  final DateTime sessionDate;
  final String reflection;

  SubmitReflectionAnswerDto({
    required this.exerciseId,
    required this.sessionDate,
    required this.reflection,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'sessionDate': sessionDate.toIso8601String(),
    'reflection': reflection,
  };

  @override
  String toString() =>
      'SubmitReflectionAnswerDto(exerciseId: $exerciseId, '
      'reflection: ${reflection.length} chars)';
}
