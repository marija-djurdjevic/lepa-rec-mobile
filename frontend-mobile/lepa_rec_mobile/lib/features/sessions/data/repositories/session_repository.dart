import '../datasources/session_remote_datasource.dart';
import '../dtos/complete_primer_dto.dart';
import '../dtos/daily_session_state_dto.dart';
import '../dtos/distanced_journal_exercise_dto.dart';
import '../dtos/growth_message_dto.dart';
import '../dtos/perspective_scenario_exercise_dto.dart';
import '../dtos/primer_statement_dto.dart';
import '../dtos/start_perspective_scenario_dto.dart';
import '../dtos/start_distanced_journal_exercise_dto.dart';
import '../dtos/submit_perspective_scenario_answer_dto.dart';
import '../dtos/submit_perspective_scenario_result_dto.dart';
import '../dtos/submit_distanced_journal_answer_dto.dart';
import '../dtos/submit_reflection_answer_dto.dart';
import '../dtos/today_practice_plan_dto.dart';

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
  ) => _remote.startDistancedJournalExercise(startRequest);

  Future<SubmitDistancedJournalResultDto> submitDistancedJournalAnswer(
    SubmitDistancedJournalAnswerDto submitRequest,
  ) => _remote.submitDistancedJournalAnswer(submitRequest);

  Future<void> submitReflectionAnswer(
    SubmitReflectionAnswerDto submitRequest,
  ) => _remote.submitReflectionAnswer(submitRequest);

  Future<PerspectiveScenarioExerciseDto> startPerspectiveScenario(
    StartPerspectiveScenarioDto startRequest,
  ) => _remote.startPerspectiveScenario(startRequest);

  Future<SubmitPerspectiveScenarioResultDto> submitPerspectiveScenario(
    SubmitPerspectiveScenarioAnswerDto submitRequest,
  ) => _remote.submitPerspectiveScenario(submitRequest);
}
