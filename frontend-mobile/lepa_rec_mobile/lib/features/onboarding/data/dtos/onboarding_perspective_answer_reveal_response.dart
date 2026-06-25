class OnboardingPerspectiveAnswerRevealResponse {
  static const String statusNeedsGuidance = 'needs_guidance';
  static const String statusCompleted = 'completed';
  static const String statusMaxIterationsReached = 'max_iterations_reached';

  final String reveal;
  final bool isExerciseCompleted;
  final int answeredQuestionsCount;
  final int totalQuestions;
  final String status;
  final String? guideQuestion;
  final int guideIterationCount;
  final String? feedback;

  const OnboardingPerspectiveAnswerRevealResponse({
    required this.reveal,
    required this.isExerciseCompleted,
    required this.answeredQuestionsCount,
    required this.totalQuestions,
    required this.status,
    required this.guideQuestion,
    required this.guideIterationCount,
    required this.feedback,
  });

  bool get needsGuidance => status == statusNeedsGuidance;

  bool get isFinalStatus =>
      status == statusCompleted || status == statusMaxIterationsReached;

  factory OnboardingPerspectiveAnswerRevealResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic rawReveal = json['reveal'] ?? json['revealText'];
    final String revealText;
    if (rawReveal is String) {
      revealText = rawReveal;
    } else if (rawReveal is Map<String, dynamic>) {
      revealText =
          (rawReveal['reveal'] as String?) ??
          (rawReveal['text'] as String?) ??
          '';
    } else {
      revealText = '';
    }

    final dynamic rawGuideQuestion = json['guideQuestion'];
    final String? guideQuestion;
    if (rawGuideQuestion is String) {
      guideQuestion = rawGuideQuestion;
    } else if (rawGuideQuestion is Map<String, dynamic>) {
      guideQuestion = rawGuideQuestion['question'] as String?;
    } else {
      guideQuestion = null;
    }

    return OnboardingPerspectiveAnswerRevealResponse(
      reveal: revealText,
      isExerciseCompleted: (json['isExerciseCompleted'] as bool?) ?? false,
      answeredQuestionsCount: _toInt(json['answeredQuestionsCount']) ?? 0,
      totalQuestions: _toInt(json['totalQuestions']) ?? 0,
      status: _toString(json['status']) ?? '',
      guideQuestion: guideQuestion,
      guideIterationCount: _toInt(json['guideIterationCount']) ?? 0,
      feedback: _toString(json['feedback']),
    );
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
