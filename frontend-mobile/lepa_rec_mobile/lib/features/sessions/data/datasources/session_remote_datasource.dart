import 'dart:io';

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
    List<String>? developedSkillIds,
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
      if (developedSkillIds != null && developedSkillIds.isNotEmpty) {
        final normalizedSkillIds = developedSkillIds
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();
        if (normalizedSkillIds.isNotEmpty) {
          queryParameters['developedSkillIds'] = normalizedSkillIds;
        }
      }

      final response = await ApiClient.dio.get(
        path,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
        options: Options(listFormat: ListFormat.multi),
      );

      final message = GrowthMessageDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return message;
    } catch (e) {
      rethrow;
    }
  }

  Future<DailySessionStateDto> recordExercise({
    required String exerciseId,
    required String type,
  }) async {
    const path = '$_baseEndpoint/exercises/record';
    final typeValue = _mapRecordExerciseType(type);

    try {
      final response = await _postRecordExercise(
        path: path,
        payload: {
          'exerciseId': exerciseId,
          'type': typeValue,
        },
      );

      final dto = DailySessionStateDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return dto;
    } on DioException catch (e) {
      // Compatibility fallbacks for different backend binding signatures.
      if (e.response?.statusCode == 400) {
        final fallbackPayloads = <Map<String, dynamic>>[
          {
            'dto': {
              'exerciseId': exerciseId,
              'type': typeValue,
            },
          },
          {
            'exerciseId': exerciseId,
            'type': type,
          },
        ];

        for (final payload in fallbackPayloads) {
          try {
            final response = await _postRecordExercise(
              path: path,
              payload: payload,
            );
            final dto = DailySessionStateDto.fromJson(
              response.data as Map<String, dynamic>,
            );
            return dto;
          } on DioException {
            // try next fallback
          }
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> _postRecordExercise({
    required String path,
    required Map<String, dynamic> payload,
  }) {
    return ApiClient.dio.post(path, data: payload);
  }

  int _mapRecordExerciseType(String type) {
    switch (type) {
      case 'DistancedJournal':
        return 0;
      case 'DistancedJournalReflection':
        return 1;
      case 'PerspectiveScenario':
        return 2;
      default:
        return 0;
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
      final raw = response.data as Map<String, dynamic>;

      if (kDebugMode) {
        final rawKeys = raw.keys.toList()..sort();
        debugPrint('[today-plan][remote][raw-keys] $rawKeys');
        debugPrint(
          '[today-plan][remote][raw-completion] '
          'isDistancedJournalCompleted=${raw['isDistancedJournalCompleted']} '
          'distancedJournalCompleted=${raw['distancedJournalCompleted']} '
          'isJournalCompleted=${raw['isJournalCompleted']} '
          'journalCompleted=${raw['journalCompleted']} '
          'isReflectionCompleted=${raw['isReflectionCompleted']} '
          'reflectionCompleted=${raw['reflectionCompleted']} '
          'isPerspectiveScenarioCompleted=${raw['isPerspectiveScenarioCompleted']} '
          'perspectiveScenarioCompleted=${raw['perspectiveScenarioCompleted']}',
        );
      }

      final dto = TodayPracticePlanDto.fromJson(
        raw,
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
          'journalOpening="${firstJournal?.openingQuestion ?? ''}" '
          'journalContent="${firstJournal?.content ?? ''}" '
          'journalFollowUp="${firstJournal?.followUpQuestion ?? ''}" '
          'scenarioText="${firstScenario?.scenarioText ?? ''}" '
          'questionText="${firstQuestion?.questionText ?? ''}" '
          'reflectionChallenge="${dto.reflectionPrompt?.challengeContent ?? ''}" '
          'reflectionQuestion="${dto.reflectionPrompt?.reflectionQuestion ?? ''}"',
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
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        final fallbackResponse = await ApiClient.dio.post(
          '/DistancedJournals/answer',
          data: submitRequest.toJson(),
          queryParameters: {'lang': _normalizeLang(lang)},
        );
        final fallbackDto = SubmitDistancedJournalResultDto.fromJson(
          fallbackResponse.data as Map<String, dynamic>,
        );
        debugPrint(
          '[DistancedJournal][Remote] SUBMIT FALLBACK TO /answer OK',
        );
        return fallbackDto;
      }
      debugPrint(
        '[DistancedJournal][Remote] ANSWER ERROR '
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
    final photoSizes = <String, int>{};
    for (final photoPath in photoPaths) {
      try {
        photoSizes[photoPath.split(RegExp(r'[\\\\/]+')).last] =
            await File(photoPath).length();
      } catch (_) {
        photoSizes[photoPath.split(RegExp(r'[\\\\/]+')).last] = -1;
      }
    }
    final totalPhotoBytes = photoSizes.values
        .where((size) => size > 0)
        .fold<int>(0, (sum, size) => sum + size);

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
      'totalPhotoBytes=$totalPhotoBytes '
      'photoFiles=${photoSizes.entries.map((entry) => '${entry.key}:${entry.value}').toList()}',
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
        '[DistancedJournal][Remote] ANSWER-WITH-PHOTOS ERROR '
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
