class OnboardingDistancedJournalSubmitResponse {
  final String? generatedReflectionQuestion;

  const OnboardingDistancedJournalSubmitResponse({
    required this.generatedReflectionQuestion,
  });

  factory OnboardingDistancedJournalSubmitResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return OnboardingDistancedJournalSubmitResponse.fromJson(data);
    }

    final exercise = json['exercise'];
    if (exercise is Map<String, dynamic>) {
      final question = _toString(
        exercise['generatedReflectionQuestion'] ??
            exercise['reflectionQuestion'],
      );
      return OnboardingDistancedJournalSubmitResponse(
        generatedReflectionQuestion: question,
      );
    }

    return OnboardingDistancedJournalSubmitResponse(
      generatedReflectionQuestion: _toString(
        json['generatedReflectionQuestion'] ?? json['reflectionQuestion'],
      ),
    );
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value;
    final text = value.toString();
    return text.trim().isEmpty ? null : text;
  }
}
