enum HistoryItemType { distancedJournal, perspectiveScenario }

class HistoryQuestion {
  final String id;
  final String text;

  const HistoryQuestion({required this.id, required this.text});
}

class HistoryAnswer {
  final String questionId;
  final String questionText;
  final String answerText;
  final String? revealText;

  const HistoryAnswer({
    required this.questionId,
    required this.questionText,
    required this.answerText,
    this.revealText,
  });
}

class HistoryItem {
  final HistoryItemType type;
  final String exerciseId;
  final String challengeId;
  final DateTime submittedAt;

  // Prompts
  final String promptText;
  final String? followUpPrompt;
  final String? reveal;
  final List<HistoryQuestion> questions;

  // Answers
  final String? mainAnswer;
  final String? followUpAnswer;
  final String? reflection;
  final String? reflectionQuestion;
  final String? generatedReflectionQuestion;
  final String? generatedReflectionAnswer;
  final List<String> photoUrls;
  final List<HistoryAnswer> answers;

  const HistoryItem.distancedJournal({
    required this.exerciseId,
    required this.challengeId,
    required this.submittedAt,
    required this.promptText,
    this.followUpPrompt,
    this.mainAnswer,
    this.followUpAnswer,
    this.reflection,
    this.reflectionQuestion,
    this.generatedReflectionQuestion,
    this.generatedReflectionAnswer,
    this.photoUrls = const [],
  }) : type = HistoryItemType.distancedJournal,
       reveal = null,
       questions = const [],
       answers = const [];

  const HistoryItem.perspectiveScenario({
    required this.exerciseId,
    required this.challengeId,
    required this.submittedAt,
    required this.promptText,
    required this.questions,
    required this.answers,
    this.reveal,
  }) : type = HistoryItemType.perspectiveScenario,
       followUpPrompt = null,
       mainAnswer = null,
       followUpAnswer = null,
       reflection = null,
       reflectionQuestion = null,
       generatedReflectionQuestion = null,
       generatedReflectionAnswer = null,
       photoUrls = const [];

  String get safePromptText =>
      promptText.trim().isEmpty ? 'Prompt unavailable' : promptText.trim();
}
