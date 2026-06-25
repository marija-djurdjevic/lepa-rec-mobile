import 'distanced_journal_challenge_dto.dart';
import 'perspective_scenario_prompt_dto.dart';
import 'reward_progress_dto.dart';
import 'today_practice_task_dto.dart';
import 'package:flutter/foundation.dart';

class TodayPracticePlanDto {
  final DistancedJournalReflectionPromptDto? reflectionPrompt;
  final List<DistancedJournalChallengeDto> distancedJournalChoices;
  final List<PerspectiveScenarioPromptDto> perspectiveScenarioChoices;
  final bool shouldShowPerspectiveScenario;
  final bool isDistancedJournalCompleted;
  final bool isReflectionCompleted;
  final bool isPerspectiveScenarioCompleted;
  final RewardProgressDto? currentReward;

  TodayPracticePlanDto({
    this.reflectionPrompt,
    required this.distancedJournalChoices,
    required this.perspectiveScenarioChoices,
    required this.shouldShowPerspectiveScenario,
    this.isDistancedJournalCompleted = false,
    this.isReflectionCompleted = false,
    this.isPerspectiveScenarioCompleted = false,
    this.currentReward,
  });

  factory TodayPracticePlanDto.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('[today-plan][raw] keys=${json.keys.join(',')}');
      debugPrint(
        '[today-plan][raw] distancedJournalChoicesType=${json['distancedJournalChoices']?.runtimeType}',
      );
    }

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
    final currentRewardJson = json['currentReward'] is Map<String, dynamic>
        ? json['currentReward'] as Map<String, dynamic>
        : null;
    final currentReward = currentRewardJson != null
        ? RewardProgressDto.fromJson(currentRewardJson)
        : null;

    if (kDebugMode) {
      for (int i = 0; i < distancedJournalChoices.length; i++) {
        final c = distancedJournalChoices[i];
        debugPrint(
          '[today-plan][choice#$i] id=${c.id} '
          'opening="${c.openingQuestion}" '
          'content="${c.content}" '
          'followUp="${c.followUpQuestion}" '
          'theme="${c.theme}" variant="${c.variant}" phase="${c.phase}" '
          'questions=${c.questions.length}',
        );
      }
      debugPrint(
        '[today-plan][reflection] exists=${reflectionPrompt != null} '
        'reflectionQuestion="${reflectionPrompt?.reflectionQuestion ?? ''}"',
      );
    }

    final isDistancedJournalCompleted = _readBoolByKeys(json, const [
      'isDistancedJournalCompleted',
      'distancedJournalCompleted',
      'isJournalCompleted',
      'journalCompleted',
    ]);
    final isReflectionCompleted = _readBoolByKeys(json, const [
      'isReflectionCompleted',
      'reflectionCompleted',
    ]);
    final isPerspectiveScenarioCompleted = _readBoolByKeys(json, const [
      'isPerspectiveScenarioCompleted',
      'perspectiveScenarioCompleted',
    ]);

    if (kDebugMode) {
      debugPrint(
        '[today-plan][completion] '
        'journal=$isDistancedJournalCompleted '
        'reflection=$isReflectionCompleted '
        'perspective=$isPerspectiveScenarioCompleted',
      );
    }

    return TodayPracticePlanDto(
      reflectionPrompt: reflectionPrompt,
      distancedJournalChoices: distancedJournalChoices,
      perspectiveScenarioChoices: perspectiveScenarioChoices,
      shouldShowPerspectiveScenario:
          json['shouldShowPerspectiveScenario'] as bool? ?? false,
      isDistancedJournalCompleted: isDistancedJournalCompleted,
      isReflectionCompleted: isReflectionCompleted,
      isPerspectiveScenarioCompleted: isPerspectiveScenarioCompleted,
      currentReward: currentReward,
    );
  }

  TodayPracticePlanDto copyWith({
    DistancedJournalReflectionPromptDto? reflectionPrompt,
    List<DistancedJournalChallengeDto>? distancedJournalChoices,
    List<PerspectiveScenarioPromptDto>? perspectiveScenarioChoices,
    bool? shouldShowPerspectiveScenario,
    bool? isDistancedJournalCompleted,
    bool? isReflectionCompleted,
    bool? isPerspectiveScenarioCompleted,
    RewardProgressDto? currentReward,
  }) {
    return TodayPracticePlanDto(
      reflectionPrompt: reflectionPrompt ?? this.reflectionPrompt,
      distancedJournalChoices:
          distancedJournalChoices ?? this.distancedJournalChoices,
      perspectiveScenarioChoices:
          perspectiveScenarioChoices ?? this.perspectiveScenarioChoices,
      shouldShowPerspectiveScenario:
          shouldShowPerspectiveScenario ?? this.shouldShowPerspectiveScenario,
      isDistancedJournalCompleted:
          isDistancedJournalCompleted ?? this.isDistancedJournalCompleted,
      isReflectionCompleted:
          isReflectionCompleted ?? this.isReflectionCompleted,
      isPerspectiveScenarioCompleted:
          isPerspectiveScenarioCompleted ?? this.isPerspectiveScenarioCompleted,
      currentReward: currentReward ?? this.currentReward,
    );
  }

  static bool _readBoolByKeys(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      final parsed = _parseBoolLike(value);
      if (parsed != null) return parsed;
    }
    return false;
  }

  static bool? _parseBoolLike(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
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
    'currentReward': currentReward?.toJson(),
  };

  @override
  String toString() =>
      'TodayPracticePlanDto(reflectionPrompt: $reflectionPrompt, '
      'distancedJournalChoices: ${distancedJournalChoices.length}, '
      'perspectiveScenarioChoices: ${perspectiveScenarioChoices.length}, '
      'shouldShowPerspectiveScenario: $shouldShowPerspectiveScenario, '
      'isDistancedJournalCompleted: $isDistancedJournalCompleted, '
      'isReflectionCompleted: $isReflectionCompleted, '
      'isPerspectiveScenarioCompleted: $isPerspectiveScenarioCompleted, '
      'currentReward: $currentReward)';
}
