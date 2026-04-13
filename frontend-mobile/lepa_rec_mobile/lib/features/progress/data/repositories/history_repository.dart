import '../datasources/history_remote_datasource.dart';
import '../dtos/perspective_scenario_challenge_dto.dart';
import '../models/history_item.dart';
import '../../../sessions/data/dtos/distanced_journal_challenge_dto.dart';
import '../../../sessions/data/dtos/distanced_journal_exercise_dto.dart';
import '../../../sessions/data/dtos/perspective_scenario_exercise_dto.dart';

class HistoryRepository {
  HistoryRepository({HistoryRemoteDataSource? remote})
      : _remote = remote ?? HistoryRemoteDataSource();

  final HistoryRemoteDataSource _remote;

  static List<DistancedJournalChallengeDto>? _cachedJournalChallenges;
  static List<PerspectiveScenarioChallengeDto>? _cachedScenarioChallenges;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheTtl = Duration(hours: 12);

  Future<List<HistoryItem>> getHistory() async {
    final challengeBundle = await _getChallenges();
    final results = await Future.wait([
      _remote.getDistancedJournalExercises(),
      _remote.getPerspectiveScenarioExercises(),
    ]);

    final journalExercises = results[0] as List<DistancedJournalExerciseDto>;
    final scenarioExercises = results[1] as List<PerspectiveScenarioExerciseDto>;

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

    historyItems.sort(
      (a, b) => b.submittedAt.compareTo(a.submittedAt),
    );

    return historyItems;
  }

  Future<_ChallengeBundle> _getChallenges() async {
    if (_isCacheValid()) {
      return _ChallengeBundle(
        journalChallenges: _cachedJournalChallenges ?? const [],
        scenarioChallenges: _cachedScenarioChallenges ?? const [],
      );
    }

    final results = await Future.wait([
      _remote.getDistancedJournalChallenges(),
      _remote.getPerspectiveScenarioChallenges(),
    ]);

    _cachedJournalChallenges = results[0] as List<DistancedJournalChallengeDto>;
    _cachedScenarioChallenges =
        results[1] as List<PerspectiveScenarioChallengeDto>;
    _cacheTimestamp = DateTime.now();

    return _ChallengeBundle(
      journalChallenges: _cachedJournalChallenges ?? const [],
      scenarioChallenges: _cachedScenarioChallenges ?? const [],
    );
  }

  bool _isCacheValid() {
    if (_cacheTimestamp == null) return false;
    final age = DateTime.now().difference(_cacheTimestamp!);
    return age < _cacheTtl;
  }

  List<HistoryItem> _mapJournalHistory(
    List<DistancedJournalExerciseDto> exercises,
    List<DistancedJournalChallengeDto> challenges,
  ) {
    final challengeMap = {
      for (final challenge in challenges) challenge.id: challenge,
    };

    return exercises
        .where((exercise) => exercise.isCompleted)
        .map(
          (exercise) {
            final challenge = challengeMap[exercise.challengeId];
            final submittedAt =
                exercise.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            return HistoryItem.distancedJournal(
              exerciseId: exercise.id,
              challengeId: exercise.challengeId,
              submittedAt: submittedAt,
              promptText: challenge?.content ?? 'Prompt unavailable',
              followUpPrompt: challenge?.followUpQuestion,
              mainAnswer: exercise.mainAnswer,
              followUpAnswer: exercise.followUpAnswer,
              reflection: exercise.reflection,
              photoUrls: exercise.photoUrls,
            );
          },
        )
        .toList();
  }

  List<HistoryItem> _mapScenarioHistory(
    List<PerspectiveScenarioExerciseDto> exercises,
    List<PerspectiveScenarioChallengeDto> challenges,
  ) {
    final challengeMap = {
      for (final challenge in challenges) challenge.id: challenge,
    };

    return exercises
        .where((exercise) => exercise.isCompleted)
        .map(
          (exercise) {
            final challenge = challengeMap[exercise.challengeId];
            final questions = (challenge?.questions ?? const [])
                .map(
                  (question) => HistoryQuestion(
                    id: question.id,
                    text: question.questionText,
                  ),
                )
                .toList();
            final questionTextMap = {
              for (final question in questions) question.id: question.text,
            };
            final answers = exercise.answers
                .map(
                  (answer) => HistoryAnswer(
                    questionId: answer.questionId,
                    questionText:
                        questionTextMap[answer.questionId] ?? 'Question',
                    answerText: answer.answerText,
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
              reveal: challenge?.reveal,
              questions: questions,
              answers: answers,
            );
          },
        )
        .toList();
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
