import 'distanced_journal_challenge_dto.dart';
import 'perspective_scenario_prompt_dto.dart';
import 'today_practice_task_dto.dart';

class TodayPracticePlanDto {
  final DistancedJournalReflectionPromptDto? reflectionPrompt;
  final List<DistancedJournalChallengeDto> distancedJournalChoices;
  final List<PerspectiveScenarioPromptDto> perspectiveScenarioChoices;
  final bool shouldShowPerspectiveScenario;
  final bool isDistancedJournalCompleted;
  final bool isReflectionCompleted;
  final bool isPerspectiveScenarioCompleted;

  TodayPracticePlanDto({
    this.reflectionPrompt,
    required this.distancedJournalChoices,
    required this.perspectiveScenarioChoices,
    required this.shouldShowPerspectiveScenario,
    this.isDistancedJournalCompleted = false,
    this.isReflectionCompleted = false,
    this.isPerspectiveScenarioCompleted = false,
  });

  factory TodayPracticePlanDto.fromJson(Map<String, dynamic> json) {
    final journalChoicesList =
        json['distancedJournalChoices'] as List<dynamic>? ?? [];
    final distancedJournalChoices = journalChoicesList
        .map(
          (item) => DistancedJournalChallengeDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final reflectionPromptJson =
        json['reflectionPrompt'] as Map<String, dynamic>?;
    final reflectionPrompt = reflectionPromptJson != null
        ? DistancedJournalReflectionPromptDto.fromJson(reflectionPromptJson)
        : null;
    final perspectiveScenarioChoicesList =
        json['perspectiveScenarioChoices'] as List<dynamic>? ?? [];
    final perspectiveScenarioChoices = perspectiveScenarioChoicesList
        .map(
          (item) => PerspectiveScenarioPromptDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    return TodayPracticePlanDto(
      reflectionPrompt: reflectionPrompt,
      distancedJournalChoices: distancedJournalChoices,
      perspectiveScenarioChoices: perspectiveScenarioChoices,
      shouldShowPerspectiveScenario:
          json['shouldShowPerspectiveScenario'] as bool? ?? false,
      isDistancedJournalCompleted:
          json['isDistancedJournalCompleted'] as bool? ?? false,
      isReflectionCompleted: json['isReflectionCompleted'] as bool? ?? false,
      isPerspectiveScenarioCompleted:
          json['isPerspectiveScenarioCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'reflectionPrompt': reflectionPrompt?.toJson(),
    'distancedJournalChoices': distancedJournalChoices
        .map((c) => c.toJson())
        .toList(),
    'perspectiveScenarioChoices': perspectiveScenarioChoices
        .map((choice) => choice.toJson())
        .toList(),
    'shouldShowPerspectiveScenario': shouldShowPerspectiveScenario,
    'isDistancedJournalCompleted': isDistancedJournalCompleted,
    'isReflectionCompleted': isReflectionCompleted,
    'isPerspectiveScenarioCompleted': isPerspectiveScenarioCompleted,
  };

  @override
  String toString() =>
      'TodayPracticePlanDto(reflectionPrompt: $reflectionPrompt, '
      'distancedJournalChoices: ${distancedJournalChoices.length}, '
      'perspectiveScenarioChoices: ${perspectiveScenarioChoices.length}, '
      'shouldShowPerspectiveScenario: $shouldShowPerspectiveScenario, '
      'isDistancedJournalCompleted: $isDistancedJournalCompleted, '
      'isReflectionCompleted: $isReflectionCompleted, '
      'isPerspectiveScenarioCompleted: $isPerspectiveScenarioCompleted)';
}
