import '../../../../core/network/api_client.dart';
import '../models/complete_primer_dto.dart';
import '../models/daily_session_state_dto.dart';
import '../models/distanced_journal_exercise_dto.dart';
import '../models/growth_message_dto.dart';
import '../models/primer_statement_dto.dart';
import '../models/start_distanced_journal_exercise_dto.dart';
import '../models/submit_distanced_journal_answer_dto.dart';
import '../models/today_practice_plan_dto.dart';

class SessionRemoteDataSource {
  static const String _baseEndpoint = '/sessions';

  Future<DailySessionStateDto> getTodaySession() async {
    const path = '$_baseEndpoint/today';

    try {
      final response = await ApiClient.dio.get(path);

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
      
      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<DailySessionStateDto> completePrimer() async {
    const path = '$_baseEndpoint/primer/complete';

    try {
      final response = await ApiClient.dio.post(
        path,
        data: {},
      );

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
    
      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completePrimerWithData(CompletePrimerDto primerData) async {
    const path = '$_baseEndpoint/primer/complete';
    try {
      final response = await ApiClient.dio.post(
        path,
        data: primerData.toJson(),
      );

    } catch (e) {
      rethrow;
    }
  }

  Future<List<PrimerStatementDto>> getRandomPrimerStatements() async {
    const path = '/practice/affirmation-values/random-statements';

    try {
      final response = await ApiClient.dio.get(path);

      final List<dynamic> jsonList = response.data as List<dynamic>;
      final statements = jsonList
          .map((json) =>
              PrimerStatementDto.fromJson(json as Map<String, dynamic>))
          .toList();

      return statements;
    } catch (e) {
      rethrow;
    }
  }

  Future<GrowthMessageDto> getRandomGrowthMessage() async {
    const path = '/practice/growth-messages/random';

    try {
      final response = await ApiClient.dio.get(path);

      final message =
          GrowthMessageDto.fromJson(response.data as Map<String, dynamic>);

      return message;
    } catch (e) {
      rethrow;
    }
  }

  Future<DailySessionStateDto> recordExercise(String exerciseName) async {
    const path = '$_baseEndpoint/exercises/record';

    try {
      final response = await ApiClient.dio.post(
        path,
        data: {'exerciseName': exerciseName},
      );

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
     
      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<DailySessionStateDto> completeSession() async {
    const path = '$_baseEndpoint/complete';

    try {
      final response = await ApiClient.dio.post(path);

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
     
      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<TodayPracticePlanDto> getTodaysPracticePlan() async {
    const path = '$_baseEndpoint/today-plan';

    try {
      final response = await ApiClient.dio.get(path);

      final dto = TodayPracticePlanDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<DistancedJournalExerciseDto> startDistancedJournalExercise(
    StartDistancedJournalExerciseDto startRequest,
  ) async {
    const path = '/DistancedJournals/start';

    try {
      final response = await ApiClient.dio.post(
        path,
        data: startRequest.toJson(),
      );

      final dto = DistancedJournalExerciseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitDistancedJournalAnswer(
    SubmitDistancedJournalAnswerDto submitRequest,
  ) async {
    const path = '/DistancedJournals/submit';

    try {
      await ApiClient.dio.post(
        path,
        data: submitRequest.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}