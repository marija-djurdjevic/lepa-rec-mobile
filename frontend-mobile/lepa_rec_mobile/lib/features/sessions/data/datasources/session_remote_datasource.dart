import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../dtos/answer_perspective_scenario_question_dto.dart';
import '../dtos/answer_perspective_scenario_reveal_result_dto.dart';
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
  final String? feedbackType;

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

  static String? _mapFeedbackType(dynamic value) {
    if (value == null) return null;
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

  String _normalizeLang(String? lang) {
    return lang == 'en' ? 'en' : 'sr';
  }

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

  Future<List<PrimerStatementDto>> getRandomPrimerStatements({
    String? lang,
  }) async {
    const path = '/practice/affirmation-values/random-statements';

    try {
      final response = await ApiClient.dio.get(
        path,
        queryParameters: {'lang': _normalizeLang(lang)},
      );

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
    String? selectedStatementId,
    String? lang,
  }) async {
    const path = '/practice/growth-messages/random';

    try {
      final queryParameters = <String, dynamic>{
        'lang': _normalizeLang(lang),
      };
      if (type != null) {
        queryParameters['type'] = type.apiValue;
      }
      if (selectedStatementId != null && selectedStatementId.trim().isNotEmpty) {
        queryParameters['selectedStatementId'] = selectedStatementId;
      }

      final response = await ApiClient.dio.get(
        path,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
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

  Future<TodayPracticePlanDto> getTodaysPracticePlan({
    String? lang,
  }) async {
    const path = '$_baseEndpoint/today-plan';
    final resolvedLang = _normalizeLang(lang);

    try {
      final response = await ApiClient.dio.get(
        path,
        queryParameters: {'lang': resolvedLang},
      );

      final dto = TodayPracticePlanDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (kDebugMode) {
        final firstJournal = dto.distancedJournalChoices.isNotEmpty
            ? dto.distancedJournalChoices.first
            : null;
        final firstScenario = dto.perspectiveScenarioChoices.isNotEmpty
            ? dto.perspectiveScenarioChoices.first
            : null;
        final firstQuestion =
            (firstScenario != null && firstScenario.questions.isNotEmpty)
            ? firstScenario.questions.first
            : null;

        debugPrint(
          '[L10N][today-plan] lang=$resolvedLang '
          'journalContent="${firstJournal?.content ?? ''}" '
          'journalFollowUp="${firstJournal?.followUpQuestion ?? ''}" '
          'scenarioText="${firstScenario?.scenarioText ?? ''}" '
          'questionText="${firstQuestion?.questionText ?? ''}" '
          'reflectionChallenge="${dto.reflectionPrompt?.challengeContent ?? ''}"',
        );
      }

      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<DistancedJournalExerciseDto> startDistancedJournalExercise(
    StartDistancedJournalExerciseDto startRequest,
    String? lang,
  ) async {
    const path = '/DistancedJournals/start';

    try {
      debugPrint('[DistancedJournal][Remote] POST $path');
      final response = await ApiClient.dio.post(
        path,
        data: startRequest.toJson(),
        queryParameters: {'lang': _normalizeLang(lang)},
      );

      final dto = DistancedJournalExerciseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      debugPrint(
        '[DistancedJournal][Remote] START OK id=${dto.id}',
      );
      return dto;
    } catch (e) {
      debugPrint('[DistancedJournal][Remote] START ERROR $e');
      rethrow;
    }
  }

  Future<SubmitDistancedJournalResultDto> submitDistancedJournalAnswer(
    SubmitDistancedJournalAnswerDto submitRequest,
    String? lang,
  ) async {
    debugPrint('[DistancedJournal][Remote] POST /DistancedJournals/submit');
    try {
      final response = await ApiClient.dio.post(
        '/DistancedJournals/submit',
        data: submitRequest.toJson(),
        queryParameters: {'lang': _normalizeLang(lang)},
      );

      final dto = SubmitDistancedJournalResultDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      debugPrint('[DistancedJournal][Remote] SUBMIT OK');
      return dto;
    } on DioException catch (e) {
      debugPrint(
        '[DistancedJournal][Remote] SUBMIT ERROR '
        'status=${e.response?.statusCode} message=${e.message} '
        'data=${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[DistancedJournal][Remote] SUBMIT ERROR $e');
      rethrow;
    }
  }

  Future<SubmitDistancedJournalResultDto>
      submitDistancedJournalAnswerWithPhotos({
        required String exerciseId,
        required DateTime sessionDate,
        String? mainAnswer,
        String? followUpAnswer,
        String? reflection,
        required List<String> photoPaths,
        String? lang,
      }) async {
    debugPrint(
      '[DistancedJournal][Remote] POST /DistancedJournals/submit-with-photos '
      'photos=${photoPaths.length}',
    );
    debugPrint(
      '[DistancedJournal][Remote] submit-with-photos payload '
      'exerciseId=$exerciseId '
      'sessionDate=${sessionDate.toIso8601String()} '
      'mainAnswer=${mainAnswer == null ? 'null' : mainAnswer.length} '
      'followUpAnswer=${followUpAnswer == null ? 'null' : followUpAnswer.length} '
      'reflection=${reflection == null ? 'null' : reflection.length} '
      'photoFiles=${photoPaths.map((p) => p.split(RegExp(r'[\\\\/]+')).last).toList()}',
    );
    final formData = FormData.fromMap({
      'exerciseId': exerciseId,
      'sessionDate': sessionDate.toIso8601String(),
      if (mainAnswer != null) 'mainAnswer': mainAnswer,
      if (followUpAnswer != null) 'followUpAnswer': followUpAnswer,
      if (reflection != null) 'reflection': reflection,
      if (photoPaths.isNotEmpty)
        'photos': [
          for (final photoPath in photoPaths)
            await MultipartFile.fromFile(
              photoPath,
              filename: photoPath.split(RegExp(r'[\\\\/]+')).last,
            ),
        ],
    });

    try {
      final response = await ApiClient.dio.post(
        '/DistancedJournals/submit-with-photos',
        data: formData,
        queryParameters: {'lang': _normalizeLang(lang)},
        options: Options(contentType: 'multipart/form-data'),
      );

      final dto = SubmitDistancedJournalResultDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      debugPrint('[DistancedJournal][Remote] SUBMIT-WITH-PHOTOS OK');
      return dto;
    } on DioException catch (e) {
      debugPrint(
        '[DistancedJournal][Remote] SUBMIT-WITH-PHOTOS ERROR '
        'status=${e.response?.statusCode} message=${e.message} '
        'data=${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[DistancedJournal][Remote] SUBMIT-WITH-PHOTOS ERROR $e');
      rethrow;
    }
  }

  Future<void> submitReflectionAnswer(
    SubmitReflectionAnswerDto submitRequest,
    String? lang,
  ) async {
    const path = '/DistancedJournals/reflection';

    try {
      await ApiClient.dio.post(
        path,
        data: submitRequest.toJson(),
        queryParameters: {'lang': _normalizeLang(lang)},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PerspectiveScenarioExerciseDto> startPerspectiveScenario(
    StartPerspectiveScenarioDto startRequest,
    String? lang,
  ) async {
    const path = '/PerspectiveScenarios/start';

    try {
      final response = await ApiClient.dio.post(
        path,
        data: startRequest.toJson(),
        queryParameters: {'lang': _normalizeLang(lang)},
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
    String? lang,
  ) async {
    const path = '/PerspectiveScenarios/submit';

    try {
      final response = await ApiClient.dio.post(
        path,
        data: submitRequest.toJson(),
        queryParameters: {'lang': _normalizeLang(lang)},
      );
      final dto = SubmitPerspectiveScenarioResultDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (kDebugMode) {
        final data = response.data as Map<String, dynamic>;
        debugPrint(
          '[PerspectiveScenario][Remote] SUBMIT OK '
          'reveals=${dto.reveals.length} '
          'keys=${data.keys.join(',')}',
        );
      }
      return dto;
    } catch (e) {
      rethrow;
    }
  }

  Future<AnswerPerspectiveScenarioRevealResultDto>
      answerPerspectiveScenarioAndReveal(
    AnswerPerspectiveScenarioQuestionDto answerRequest,
    String? lang,
  ) async {
    const path = '/PerspectiveScenarios/answer-and-reveal';

    final response = await ApiClient.dio.post(
      path,
      data: answerRequest.toJson(),
      queryParameters: {'lang': _normalizeLang(lang)},
    );

    return AnswerPerspectiveScenarioRevealResultDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
