class OnboardingPerspectiveAnswerRevealResponse {
  final String reveal;
  final bool isExerciseCompleted;
  final int answeredQuestionsCount;
  final int totalQuestions;

  const OnboardingPerspectiveAnswerRevealResponse({
    required this.reveal,
    required this.isExerciseCompleted,
    required this.answeredQuestionsCount,
    required this.totalQuestions,
  });

  factory OnboardingPerspectiveAnswerRevealResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawReveal = json['reveal'] ?? json['revealText'];
    final String revealText;
    if (rawReveal is String) {
      revealText = rawReveal;
    } else if (rawReveal is Map<String, dynamic>) {
      revealText = (rawReveal['reveal'] as String?) ?? (rawReveal['text'] as String?) ?? '';
    } else {
      revealText = '';
    }

    return OnboardingPerspectiveAnswerRevealResponse(
      reveal: revealText,
      isExerciseCompleted: (json['isExerciseCompleted'] as bool?) ?? false,
      answeredQuestionsCount: _toInt(json['answeredQuestionsCount']) ?? 0,
      totalQuestions: _toInt(json['totalQuestions']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
