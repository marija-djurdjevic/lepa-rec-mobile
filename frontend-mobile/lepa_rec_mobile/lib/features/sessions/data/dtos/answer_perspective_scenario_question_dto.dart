class AnswerPerspectiveScenarioQuestionDto {
  final String exerciseId;
  final String questionId;
  final String answerText;

  AnswerPerspectiveScenarioQuestionDto({
    required this.exerciseId,
    required this.questionId,
    required this.answerText,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'questionId': questionId,
    'answerText': answerText,
  };
}

