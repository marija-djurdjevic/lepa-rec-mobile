import '../../../../core/network/api_client.dart';
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
import '../dtos/submit_reflection_answer_dto.dart';
import '../dtos/today_practice_plan_dto.dart';

class SubmitDistancedJournalResultDto {
  final DistancedJournalExerciseDto exercise;
  final String feedbackType;

  SubmitDistancedJournalResultDto({
    required this.exercise,
    required this.feedbackType,
  });

  factory SubmitDistancedJournalResultDto.fromJson(Map<String, dynamic> json) {
    return SubmitDistancedJournalResultDto(
      exercise: DistancedJournalExerciseDto.fromJson(
        json['exercise'] as Map<String, dynamic>,
      ),
      feedbackType: _mapFeedbackType(json['feedbackType']),
    );
  }

  static String _mapFeedbackType(dynamic value) {
    switch (value) {
      case 0:
        return 'GoodDistancing';
      case 1:
        return 'MixedDistancing';
      case 2:
        return 'NeedsMoreDistancing';
      default:
        return value.toString();
    }
  }

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'feedbackType': feedbackType,
  };
}

class SessionRemoteDataSource {
  static const String _baseEndpoint = '/sessions';

  Future<DailySessionStateDto> getTodaySession() async {
    const path = '$_baseEndpoint/today';

    try {
      final response = await ApiClient.dio.get(path);

      final dto = DailySessionStateDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<DailySessionStateDto> completePrimer() async {
    const path = '$_baseEndpoint/primer/complete';

    try {
      final response = await ApiClient.dio.post(path, data: {});

      final dto = DailySessionStateDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completePrimerWithData(CompletePrimerDto primerData) async {
    const path = '$_baseEndpoint/primer/complete';
    try {
      await ApiClient.dio.post(
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
          .map(
            (json) => PrimerStatementDto.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return statements;
    } catch (e) {
      rethrow;
    }
  }

  Future<GrowthMessageDto> getRandomGrowthMessage({
    GrowthMessageType? type,
  }) async {
    const path = '/practice/growth-messages/random';

    try {
      final response = await ApiClient.dio.get(
        path,
        queryParameters: type == null ? null : {'type': type.apiValue},
      );

      final message = GrowthMessageDto.fromJson(
        response.data as Map<String, dynamic>,
      );

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

      final dto = DailySessionStateDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<DailySessionStateDto> completeSession() async {
    const path = '$_baseEndpoint/complete';

    try {
      final response = await ApiClient.dio.post(path);

      final dto = DailySessionStateDto.fromJson(
        response.data as Map<String, dynamic>,
      );

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

  Future<SubmitDistancedJournalResultDto> submitDistancedJournalAnswer(
    SubmitDistancedJournalAnswerDto submitRequest,
  ) async {
    final response = await ApiClient.dio.post(
      '/DistancedJournals/submit',
      data: submitRequest.toJson(),
    );

    return SubmitDistancedJournalResultDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> submitReflectionAnswer(
    SubmitReflectionAnswerDto submitRequest,
  ) async {
    const path = '/DistancedJournals/reflection';

    try {
      await ApiClient.dio.post(path, data: submitRequest.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<PerspectiveScenarioExerciseDto> startPerspectiveScenario(
    StartPerspectiveScenarioDto startRequest,
  ) async {
    const path = '/PerspectiveScenarios/start';

    try {
      final response = await ApiClient.dio.post(
        path,
        data: startRequest.toJson(),
      );

      return PerspectiveScenarioExerciseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<SubmitPerspectiveScenarioResultDto> submitPerspectiveScenario(
    SubmitPerspectiveScenarioAnswerDto submitRequest,
  ) async {
    const path = '/PerspectiveScenarios/submit';

    try {
      final response = await ApiClient.dio.post(
        path,
        data: submitRequest.toJson(),
      );

      return SubmitPerspectiveScenarioResultDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
