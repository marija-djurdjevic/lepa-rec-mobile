import '../datasources/history_remote_datasource.dart';
import 'package:flutter/foundation.dart';
import '../dtos/perspective_scenario_challenge_dto.dart';
import '../models/history_item.dart';
import '../../../sessions/data/dtos/distanced_journal_challenge_dto.dart';
import '../../../sessions/data/dtos/distanced_journal_exercise_dto.dart';
import '../../../sessions/data/dtos/perspective_scenario_exercise_dto.dart';

class HistoryRepository {
  HistoryRepository({HistoryRemoteDataSource? remote})
    : _remote = remote ?? HistoryRemoteDataSource();

  final HistoryRemoteDataSource _remote;

  static final Map<String, List<DistancedJournalChallengeDto>>
  _cachedJournalChallengesByLang = {};
  static final Map<String, List<PerspectiveScenarioChallengeDto>>
  _cachedScenarioChallengesByLang = {};
  static final Map<String, DateTime> _cacheTimestampByLang = {};
  static const Duration _cacheTtl = Duration(hours: 12);

  Future<List<HistoryItem>> getHistory({String? lang}) async {
    final resolvedLang = _normalizeLang(lang);
    final challengeBundle = await _getChallenges(resolvedLang);
    final results = await Future.wait([
      _remote.getDistancedJournalExercises(lang: resolvedLang),
      _remote.getPerspectiveScenarioExercises(lang: resolvedLang),
    ]);

    final journalExercises = results[0] as List<DistancedJournalExerciseDto>;
    final scenarioExercises =
        results[1] as List<PerspectiveScenarioExerciseDto>;

    final historyItems = <HistoryItem>[
      ..._mapJournalHistory(
        journalExercises,
        challengeBundle.journalChallenges,
      ),
      ..._mapScenarioHistory(
        scenarioExercises,
        challengeBundle.scenarioChallenges,
      ),
    ];

    historyItems.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    final dedupedHistoryItems = _dedupeByExerciseId(historyItems);

    debugPrint(
      '[History][Repo] journalRaw=${journalExercises.length} '
      'journalCompleted=${journalExercises.where((e) => e.isCompleted).length} '
      'scenarioRaw=${scenarioExercises.length} '
      'scenarioCompleted=${scenarioExercises.where((e) => e.isCompleted).length} '
      'mergedItems=${historyItems.length} '
      'dedupedItems=${dedupedHistoryItems.length}',
    );

    return dedupedHistoryItems;
  }

  List<HistoryItem> _dedupeByExerciseId(List<HistoryItem> items) {
    final byKey = <String, HistoryItem>{};
    for (final item in items) {
      final key = '${item.type}:${item.exerciseId}';
      final existing = byKey[key];
      if (existing == null || item.submittedAt.isAfter(existing.submittedAt)) {
        byKey[key] = item;
      }
    }
    final result = byKey.values.toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return result;
  }

  Future<_ChallengeBundle> _getChallenges(String lang) async {
    if (_isCacheValid(lang)) {
      return _ChallengeBundle(
        journalChallenges: _cachedJournalChallengesByLang[lang] ?? const [],
        scenarioChallenges: _cachedScenarioChallengesByLang[lang] ?? const [],
      );
    }

    final results = await Future.wait([
      _remote.getDistancedJournalChallenges(lang: lang),
      _remote.getPerspectiveScenarioChallenges(lang: lang),
    ]);

    _cachedJournalChallengesByLang[lang] =
        results[0] as List<DistancedJournalChallengeDto>;
    _cachedScenarioChallengesByLang[lang] =
        results[1] as List<PerspectiveScenarioChallengeDto>;
    _cacheTimestampByLang[lang] = DateTime.now();

    return _ChallengeBundle(
      journalChallenges: _cachedJournalChallengesByLang[lang] ?? const [],
      scenarioChallenges: _cachedScenarioChallengesByLang[lang] ?? const [],
    );
  }

  String _normalizeLang(String? lang) {
    return lang == 'en' ? 'en' : 'sr';
  }

  bool _isCacheValid(String lang) {
    final timestamp = _cacheTimestampByLang[lang];
    if (timestamp == null) return false;
    final age = DateTime.now().difference(timestamp);
    return age < _cacheTtl;
  }

  List<HistoryItem> _mapJournalHistory(
    List<DistancedJournalExerciseDto> exercises,
    List<DistancedJournalChallengeDto> challenges,
  ) {
    final challengeMap = {
      for (final challenge in challenges) challenge.id: challenge,
    };

    return exercises.where((exercise) => exercise.isCompleted).map((exercise) {
      final challenge = challengeMap[exercise.challengeId];
      final submittedAt =
          exercise.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return HistoryItem.distancedJournal(
        exerciseId: exercise.id,
        challengeId: exercise.challengeId,
        submittedAt: submittedAt,
        promptText: _composeHistoryPrompt(challenge),
        followUpPrompt: challenge?.followUpPromptText(),
        mainAnswer: exercise.mainAnswer,
        followUpAnswer: exercise.followUpAnswer,
        reflection: exercise.reflection,
        reflectionQuestion: _extractReflectionQuestion(challenge),
        generatedReflectionQuestion: exercise.generatedReflectionQuestion,
        generatedReflectionAnswer: exercise.generatedReflectionAnswer,
        photoUrls: exercise.photoUrls,
      );
    }).toList();
  }

  String? _extractReflectionQuestion(DistancedJournalChallengeDto? challenge) {
    return challenge?.reflectionPromptText();
  }

  String _composeHistoryPrompt(DistancedJournalChallengeDto? challenge) {
    if (challenge == null) return 'Prompt unavailable';
    final content = challenge.content.trim();
    final opening = challenge.openingPromptText().trim();
    if (content.isNotEmpty && opening.isNotEmpty && content != opening) {
      return '$content\n\n$opening';
    }
    if (content.isNotEmpty) return content;
    if (opening.isNotEmpty) return opening;
    return 'Prompt unavailable';
  }

  List<HistoryItem> _mapScenarioHistory(
    List<PerspectiveScenarioExerciseDto> exercises,
    List<PerspectiveScenarioChallengeDto> challenges,
  ) {
    final challengeMap = {
      for (final challenge in challenges) challenge.id: challenge,
    };

    return exercises.where((exercise) => exercise.isCompleted).map((exercise) {
      final challenge = challengeMap[exercise.challengeId];
      final questions = (challenge?.questions ?? const [])
          .map(
            (question) =>
                HistoryQuestion(id: question.id, text: question.questionText),
          )
          .toList();
      final questionTextMap = {
        for (final question in questions) question.id: question.text,
      };
      final questionRevealMap = {
        for (final question in (challenge?.questions ?? const []))
          question.id: question.reveal,
      };
      final answers = exercise.answers
          .map(
            (answer) => HistoryAnswer(
              questionId: answer.questionId,
              questionText: questionTextMap[answer.questionId] ?? 'Question',
              answerText: answer.answerText,
              revealText: questionRevealMap[answer.questionId],
            ),
          )
          .toList();
      final submittedAt =
          exercise.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return HistoryItem.perspectiveScenario(
        exerciseId: exercise.id,
        challengeId: exercise.challengeId,
        submittedAt: submittedAt,
        promptText: challenge?.scenarioText ?? 'Prompt unavailable',
        reveal: null,
        questions: questions,
        answers: answers,
      );
    }).toList();
  }
}

class _ChallengeBundle {
  final List<DistancedJournalChallengeDto> journalChallenges;
  final List<PerspectiveScenarioChallengeDto> scenarioChallenges;

  const _ChallengeBundle({
    required this.journalChallenges,
    required this.scenarioChallenges,
  });
}
