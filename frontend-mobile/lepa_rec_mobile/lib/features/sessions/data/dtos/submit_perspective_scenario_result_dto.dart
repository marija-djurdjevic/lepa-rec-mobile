import 'perspective_scenario_exercise_dto.dart';

class PerspectiveScenarioRevealDto {
  final String questionId;
  final int order;
  final String reveal;

  PerspectiveScenarioRevealDto({
    required this.questionId,
    required this.order,
    required this.reveal,
  });

  factory PerspectiveScenarioRevealDto.fromJson(Map<String, dynamic> json) {
    return PerspectiveScenarioRevealDto(
      questionId:
          _toString(json['questionId'] ?? json['questionID'] ?? json['id']) ??
          '',
      order: _toInt(json['order'] ?? json['questionOrder']) ?? 0,
      reveal:
          json['reveal'] as String? ??
          json['revealText'] as String? ??
          json['text'] as String? ??
          '',
    );
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'order': order,
    'reveal': reveal,
  };
}

class SubmitPerspectiveScenarioResultDto {
  final PerspectiveScenarioExerciseDto exercise;
  final List<PerspectiveScenarioRevealDto> reveals;

  SubmitPerspectiveScenarioResultDto({
    required this.exercise,
    required this.reveals,
  });

  factory SubmitPerspectiveScenarioResultDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final revealsJson =
        json['reveals'] as List<dynamic>? ??
        json['questionReveals'] as List<dynamic>? ??
        ((json['exercise'] as Map<String, dynamic>?)?['reveals']
            as List<dynamic>?) ??
        [];

    return SubmitPerspectiveScenarioResultDto(
      exercise: PerspectiveScenarioExerciseDto.fromJson(
        json['exercise'] as Map<String, dynamic>,
      ),
      reveals: revealsJson
          .map(
            (item) => PerspectiveScenarioRevealDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'reveals': reveals.map((item) => item.toJson()).toList(),
  };
}
