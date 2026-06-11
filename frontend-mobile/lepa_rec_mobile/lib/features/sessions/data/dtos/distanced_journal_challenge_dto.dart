class DistancedJournalChallengeDto {
  final String id;
  final String? skillId;
  final String content;
  final String theme;
  final String variant;
  final String phase;
  final String openingQuestion;
  final String followUpQuestion;
  final String challengeLevel;
  final List<DistancedJournalQuestionDto> questions;

  DistancedJournalChallengeDto({
    required this.id,
    this.skillId,
    required this.content,
    required this.theme,
    required this.variant,
    required this.phase,
    required this.openingQuestion,
    required this.followUpQuestion,
    required this.challengeLevel,
    this.questions = const [],
  });

  factory DistancedJournalChallengeDto.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? const [];
    return DistancedJournalChallengeDto(
      id: _toString(json['id']) ?? '',
      skillId: _toString(json['skillId']),
      content: _toString(json['content']) ?? '',
      theme: _toString(json['theme']) ?? '',
      variant: _mapVariant(json['variant']),
      phase: _mapPhase(json['phase']),
      openingQuestion: _toString(json['openingQuestion']) ?? '',
      followUpQuestion: _toString(json['followUpQuestion']) ?? '',
      challengeLevel: _mapChallengeLevel(json['challengeLevel']),
      questions: questionsJson
          .map(
            (item) => DistancedJournalQuestionDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  static String _mapChallengeLevel(dynamic value) {
    switch (value) {
      case 0:
        return 'Easy';
      case 1:
        return 'Medium';
      case 2:
        return 'Hard';
      default:
        return value.toString();
    }
  }

  static String _mapVariant(dynamic value) {
    switch (value) {
      case 0:
      case '0':
        return 'A';
      case 1:
      case '1':
        return 'B';
      default:
        return value?.toString() ?? '';
    }
  }

  static String _mapPhase(dynamic value) {
    switch (value) {
      case 0:
      case '0':
        return 'A';
      case 1:
      case '1':
        return 'Single';
      case 2:
      case '2':
        return 'B';
      default:
        return value?.toString() ?? '';
    }
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'skillId': skillId,
    'content': content,
    'theme': theme,
    'variant': variant,
    'phase': phase,
    'openingQuestion': openingQuestion,
    'followUpQuestion': followUpQuestion,
    'challengeLevel': challengeLevel,
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  @override
  String toString() =>
      'DistancedJournalChallengeDto(id: $id, content: $content, '
      'challengeLevel: $challengeLevel)';

  List<DistancedJournalQuestionDto> get questionsSorted {
    final sorted = [...questions];
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  DistancedJournalQuestionDto? questionByKindOrOrder({
    required String kind,
    required int order,
  }) {
    final kindLower = kind.toLowerCase();
    for (final question in questionsSorted) {
      if (question.normalizedKind.toLowerCase() == kindLower) {
        return question;
      }
    }
    for (final question in questionsSorted) {
      if (question.order == order) {
        return question;
      }
    }
    return null;
  }

  String openingPromptText() {
    final fromQuestions = questionByKindOrOrder(kind: 'Opening', order: 1)
        ?.text
        .trim();
    if (fromQuestions != null && fromQuestions.isNotEmpty) {
      return fromQuestions;
    }
    final opening = openingQuestion.trim();
    if (opening.isNotEmpty) return opening;
    return content;
  }

  String followUpPromptText() {
    final legacy = followUpQuestion.trim();
    if (legacy.isNotEmpty) return legacy;
    final fromQuestions = questionByKindOrOrder(kind: 'FollowUp', order: 2)
        ?.text
        .trim();
    if (fromQuestions != null && fromQuestions.isNotEmpty) {
      return fromQuestions;
    }
    return '';
  }

  String? reflectionPromptText() {
    final fromQuestions = questionByKindOrOrder(kind: 'Reflection', order: 3)
        ?.text
        .trim();
    if (fromQuestions != null && fromQuestions.isNotEmpty) {
      return fromQuestions;
    }
    return null;
  }
}

class DistancedJournalQuestionDto {
  final String id;
  final String kind;
  final int order;
  final String text;
  final String? skillId;

  DistancedJournalQuestionDto({
    required this.id,
    required this.kind,
    required this.order,
    required this.text,
    this.skillId,
  });

  factory DistancedJournalQuestionDto.fromJson(Map<String, dynamic> json) {
    return DistancedJournalQuestionDto(
      id: DistancedJournalChallengeDto._toString(json['id']) ?? '',
      kind: _mapQuestionKind(json['kind']),
      order: json['order'] as int? ?? 0,
      text: DistancedJournalChallengeDto._toString(json['text']) ?? '',
      skillId: DistancedJournalChallengeDto._toString(json['skillId']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'order': order,
    'text': text,
    'skillId': skillId,
  };

  static String _mapQuestionKind(dynamic value) {
    switch (value) {
      case 0:
      case '0':
        return 'Opening';
      case 1:
      case '1':
        return 'FollowUp';
      case 2:
      case '2':
        return 'Reflection';
      default:
        return value?.toString() ?? '';
    }
  }

  String get normalizedKind {
    return _mapQuestionKind(kind);
  }
}
