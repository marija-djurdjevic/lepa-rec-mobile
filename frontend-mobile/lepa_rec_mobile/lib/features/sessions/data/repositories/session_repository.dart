import '../datasources/session_remote_datasource.dart';
import '../models/complete_primer_dto.dart';
import '../models/daily_session_state_dto.dart';
import '../models/distanced_journal_exercise_dto.dart';
import '../models/growth_message_dto.dart';
import '../models/primer_statement_dto.dart';
import '../models/start_distanced_journal_exercise_dto.dart';
import '../models/submit_distanced_journal_answer_dto.dart';
import '../models/today_practice_plan_dto.dart';

class SessionRepository {
  final SessionRemoteDataSource _remote;

  SessionRepository({SessionRemoteDataSource? remote})
      : _remote = remote ?? SessionRemoteDataSource();

  Future<DailySessionStateDto> getTodaySession() => _remote.getTodaySession();

  Future<DailySessionStateDto> completePrimer() => _remote.completePrimer();

  Future<void> completePrimerWithData(CompletePrimerDto primerData) =>
      _remote.completePrimerWithData(primerData);

  Future<DailySessionStateDto> recordExercise(String exerciseName) =>
      _remote.recordExercise(exerciseName);

  Future<DailySessionStateDto> completeSession() => _remote.completeSession();

  Future<List<PrimerStatementDto>> getRandomPrimerStatements() =>
      _remote.getRandomPrimerStatements();

  Future<GrowthMessageDto> getRandomGrowthMessage() =>
      _remote.getRandomGrowthMessage();

  Future<TodayPracticePlanDto> getTodaysPracticePlan() =>
      _remote.getTodaysPracticePlan();

  Future<DistancedJournalExerciseDto> startDistancedJournalExercise(
    StartDistancedJournalExerciseDto startRequest,
  ) =>
      _remote.startDistancedJournalExercise(startRequest);

  Future<void> submitDistancedJournalAnswer(
    SubmitDistancedJournalAnswerDto submitRequest,
  ) =>
      _remote.submitDistancedJournalAnswer(submitRequest);
}
