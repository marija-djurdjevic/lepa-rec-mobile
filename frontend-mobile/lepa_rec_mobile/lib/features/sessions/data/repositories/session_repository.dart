import '../datasources/session_remote_datasource.dart';
import '../models/complete_primer_dto.dart';
import '../models/daily_session_state_dto.dart';
import '../models/growth_message_dto.dart';
import '../models/primer_statement_dto.dart';

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
}
