import '../datasources/session_remote_datasource.dart';
import '../dtos/answer_perspective_scenario_question_dto.dart';
import '../dtos/answer_perspective_scenario_reveal_result_dto.dart';
import '../dtos/complete_session_result_dto.dart';
import '../dtos/complete_primer_dto.dart';
import '../dtos/daily_session_state_dto.dart';
import '../dtos/distanced_journal_exercise_dto.dart';
import '../dtos/growth_message_dto.dart';
import '../dtos/growth_message_type.dart';
import '../dtos/perspective_scenario_exercise_dto.dart';
import '../dtos/primer_statement_dto.dart';
import '../dtos/start_perspective_scenario_dto.dart';
import '../dtos/start_distanced_journal_exercise_dto.dart';
import '../dtos/submit_perspective_scenario_answer_dto.dart';
import '../dtos/submit_perspective_scenario_result_dto.dart';
import '../dtos/submit_distanced_journal_answer_dto.dart';
import '../dtos/submit_generated_distanced_journal_reflection_dto.dart';
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

  Future<DailySessionStateDto> recordExercise({
    required String exerciseId,
    required String type,
  }) => _remote.recordExercise(exerciseId: exerciseId, type: type);

  Future<CompleteSessionResultDto> completeSession() =>
      _remote.completeSession();

  Future<List<PrimerStatementDto>> getRandomPrimerStatements({String? lang}) =>
      _remote.getRandomPrimerStatements(lang: lang);

  Future<GrowthMessageDto> getRandomGrowthMessage({
    GrowthMessageType? type,
    String? selectedStatementId,
    List<String>? developedSkillIds,
    String? lang,
  }) => _remote.getRandomGrowthMessage(
    type: type,
    selectedStatementId: selectedStatementId,
    developedSkillIds: developedSkillIds,
    lang: lang,
  );

  Future<TodayPracticePlanDto> getTodaysPracticePlan({String? lang}) =>
      _remote.getTodaysPracticePlan(lang: lang);

  Future<DistancedJournalExerciseDto> startDistancedJournalExercise(
    StartDistancedJournalExerciseDto startRequest,
    String? lang,
  ) => _remote.startDistancedJournalExercise(startRequest, lang);

  Future<SubmitDistancedJournalResultDto> submitDistancedJournalAnswer(
    SubmitDistancedJournalAnswerDto submitRequest,
    String? lang,
  ) => _remote.submitDistancedJournalAnswer(submitRequest, lang);

  Future<SubmitDistancedJournalResultDto>
  submitDistancedJournalAnswerWithPhotos({
    required String exerciseId,
    required DateTime sessionDate,
    String? mainAnswer,
    String? followUpAnswer,
    String? reflection,
    required List<String> photoPaths,
    String? lang,
  }) => _remote.submitDistancedJournalAnswerWithPhotos(
    exerciseId: exerciseId,
    sessionDate: sessionDate,
    mainAnswer: mainAnswer,
    followUpAnswer: followUpAnswer,
    reflection: reflection,
    photoPaths: photoPaths,
    lang: lang,
  );

  Future<void> submitReflectionAnswer(
    SubmitReflectionAnswerDto submitRequest,
    String? lang,
  ) => _remote.submitReflectionAnswer(submitRequest, lang);

  Future<DistancedJournalExerciseDto> submitGeneratedDistancedJournalReflection(
    SubmitGeneratedDistancedJournalReflectionDto submitRequest,
    String? lang,
  ) => _remote.submitGeneratedDistancedJournalReflection(submitRequest, lang);

  Future<PerspectiveScenarioExerciseDto> startPerspectiveScenario(
    StartPerspectiveScenarioDto startRequest,
    String? lang,
  ) => _remote.startPerspectiveScenario(startRequest, lang);

  Future<SubmitPerspectiveScenarioResultDto> submitPerspectiveScenario(
    SubmitPerspectiveScenarioAnswerDto submitRequest,
    String? lang,
  ) => _remote.submitPerspectiveScenario(submitRequest, lang);

  Future<AnswerPerspectiveScenarioRevealResultDto>
  answerPerspectiveScenarioAndReveal(
    AnswerPerspectiveScenarioQuestionDto answerRequest,
    String? lang,
  ) => _remote.answerPerspectiveScenarioAndReveal(answerRequest, lang);

  Future<AnswerPerspectiveScenarioRevealResultDto>
  answerPerspectiveScenarioAndRevealStream(
    AnswerPerspectiveScenarioQuestionDto answerRequest,
    String? lang, {
    required void Function(String guideText) onGuideTextChanged,
  }) => _remote.answerPerspectiveScenarioAndRevealStream(
    answerRequest,
    lang,
    onGuideTextChanged: onGuideTextChanged,
  );
}
