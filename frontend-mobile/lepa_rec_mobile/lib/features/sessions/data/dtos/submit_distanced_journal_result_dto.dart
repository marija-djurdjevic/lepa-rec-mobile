import 'distanced_journal_exercise_dto.dart';

class SubmitDistancedJournalResultDto {
  final DistancedJournalExerciseDto exercise;
  final String? feedbackType;

  SubmitDistancedJournalResultDto({
    required this.exercise,
    required this.feedbackType,
  });

  factory SubmitDistancedJournalResultDto.fromJson(Map<String, dynamic> json) {
    return SubmitDistancedJournalResultDto(
      exercise: DistancedJournalExerciseDto.fromJson(
        json['exercise'] as Map<String, dynamic>,
      ),
      feedbackType: json['feedbackType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'feedbackType': feedbackType,
  };
}
