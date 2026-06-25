import 'perspective_scenario_exercise_dto.dart';
import 'submit_perspective_scenario_result_dto.dart';

class AnswerPerspectiveScenarioRevealResultDto {
  static const String statusNeedsGuidance = 'needs_guidance';
  static const String statusCompleted = 'completed';
  static const String statusMaxIterationsReached = 'max_iterations_reached';

  final PerspectiveScenarioExerciseDto exercise;
  final PerspectiveScenarioRevealDto? reveal;
  final bool isExerciseCompleted;
  final int answeredQuestionsCount;
  final int totalQuestions;
  final String status;
  final int? grade;
  final List<String> issues;
  final List<String> strengths;
  final PerspectiveScenarioGuideQuestionDto? guideQuestion;
  final int guideIterationCount;
  final String? feedback;

  AnswerPerspectiveScenarioRevealResultDto({
    required this.exercise,
    required this.reveal,
    required this.isExerciseCompleted,
    required this.answeredQuestionsCount,
    required this.totalQuestions,
    required this.status,
    required this.grade,
    required this.issues,
    required this.strengths,
    required this.guideQuestion,
    required this.guideIterationCount,
    required this.feedback,
  });

  bool get needsGuidance => status == statusNeedsGuidance;

  bool get isFinalStatus =>
      status == statusCompleted || status == statusMaxIterationsReached;

  factory AnswerPerspectiveScenarioRevealResultDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AnswerPerspectiveScenarioRevealResultDto(
      exercise: PerspectiveScenarioExerciseDto.fromJson(
        json['exercise'] as Map<String, dynamic>,
      ),
      reveal: json['reveal'] is Map<String, dynamic>
          ? PerspectiveScenarioRevealDto.fromJson(
              json['reveal'] as Map<String, dynamic>,
            )
          : null,
      isExerciseCompleted: json['isExerciseCompleted'] as bool? ?? false,
      answeredQuestionsCount: _toInt(json['answeredQuestionsCount']) ?? 0,
      totalQuestions: _toInt(json['totalQuestions']) ?? 0,
      status: _toString(json['status']) ?? '',
      grade: _toInt(json['grade']),
      issues: _toStringList(json['issues']),
      strengths: _toStringList(json['strengths']),
      guideQuestion: json['guideQuestion'] is Map<String, dynamic>
          ? PerspectiveScenarioGuideQuestionDto.fromJson(
              json['guideQuestion'] as Map<String, dynamic>,
            )
          : null,
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

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(_toString)
        .whereType<String>()
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
}

class PerspectiveScenarioGuideQuestionDto {
  final String question;

  PerspectiveScenarioGuideQuestionDto({required this.question});

  factory PerspectiveScenarioGuideQuestionDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return PerspectiveScenarioGuideQuestionDto(
      question: json['question'] as String? ?? '',
    );
  }
}
