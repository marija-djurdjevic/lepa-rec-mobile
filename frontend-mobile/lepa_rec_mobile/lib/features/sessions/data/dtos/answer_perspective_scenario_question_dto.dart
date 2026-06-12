class AnswerPerspectiveScenarioQuestionDto {
  final String exerciseId;
  final String questionId;
  final String answerText;
  final String idempotencyKey;

  AnswerPerspectiveScenarioQuestionDto({
    required this.exerciseId,
    required this.questionId,
    required this.answerText,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'questionId': questionId,
    'answerText': answerText,
    'idempotencyKey': idempotencyKey,
  };
}
