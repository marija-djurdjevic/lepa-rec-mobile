import 'distanced_journal_challenge_dto.dart';
import 'perspective_scenario_prompt_dto.dart';
import 'today_practice_task_dto.dart';

class TodayPracticePlanDto {
  final DistancedJournalReflectionPromptDto? reflectionPrompt;
  final List<DistancedJournalChallengeDto> distancedJournalChoices;
  final PerspectiveScenarioPromptDto? perspectiveScenarioPrompt;
  final bool shouldShowPerspectiveScenario;
  final bool isDistancedJournalCompleted;
  final bool isReflectionCompleted;
  final bool isPerspectiveScenarioCompleted;

  TodayPracticePlanDto({
    this.reflectionPrompt,
    required this.distancedJournalChoices,
    this.perspectiveScenarioPrompt,
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
    final perspectiveScenarioPromptJson =
        json['perspectiveScenarioPrompt'] as Map<String, dynamic>?;
    final perspectiveScenarioPrompt = perspectiveScenarioPromptJson != null
        ? PerspectiveScenarioPromptDto.fromJson(perspectiveScenarioPromptJson)
        : null;

    return TodayPracticePlanDto(
      reflectionPrompt: reflectionPrompt,
      distancedJournalChoices: distancedJournalChoices,
      perspectiveScenarioPrompt: perspectiveScenarioPrompt,
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
    'perspectiveScenarioPrompt': perspectiveScenarioPrompt?.toJson(),
    'shouldShowPerspectiveScenario': shouldShowPerspectiveScenario,
    'isDistancedJournalCompleted': isDistancedJournalCompleted,
    'isReflectionCompleted': isReflectionCompleted,
    'isPerspectiveScenarioCompleted': isPerspectiveScenarioCompleted,
  };

  @override
  String toString() =>
      'TodayPracticePlanDto(reflectionPrompt: $reflectionPrompt, '
      'distancedJournalChoices: ${distancedJournalChoices.length}, '
      'perspectiveScenarioPrompt: $perspectiveScenarioPrompt, '
      'shouldShowPerspectiveScenario: $shouldShowPerspectiveScenario, '
      'isDistancedJournalCompleted: $isDistancedJournalCompleted, '
      'isReflectionCompleted: $isReflectionCompleted, '
      'isPerspectiveScenarioCompleted: $isPerspectiveScenarioCompleted)';
}
