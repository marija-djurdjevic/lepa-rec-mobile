import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lepa_rec_mobile/features/sessions/data/dtos/perspective_scenario_exercise_dto.dart';
import 'package:lepa_rec_mobile/features/sessions/data/dtos/perspective_scenario_prompt_dto.dart';

import '../../../../core/network/api_client.dart';
import '../dtos/onboarding_distanced_journal_challenge_dto.dart';
import '../dtos/onboarding_distanced_journal_exercise_dto.dart';
import '../dtos/onboarding_perspective_answer_reveal_response.dart';
import '../dtos/onboarding_session_start_response.dart';

class OnboardingRemoteDataSource {
  final Dio _dio;

  OnboardingRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<OnboardingSessionStartResponse> startSession() async {
    const endpoint = '/onboarding/session/start';
    final response = await _dio.post(endpoint, data: <String, dynamic>{});
    return OnboardingSessionStartResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> setLanguage({
    required String onboardingSessionId,
    required String preferredLanguage,
  }) async {
    const endpoint = '/onboarding/session/language';
    await _dio.put(
      endpoint,
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'preferredLanguage': preferredLanguage,
      },
    );
  }

  Future<void> setHook({
    required String onboardingSessionId,
    required String hookType,
  }) async {
    const endpoint = '/onboarding/session/hook';
    await _dio.put(
      endpoint,
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'hookType': hookType,
        'hookChallengeId': null,
      },
    );
  }

  Future<OnboardingDistancedJournalChallengeDto> getDistancedJournalChallenge({
    required String onboardingSessionId,
    required String lang,
  }) async {
    const endpoint = '/onboarding/session/hook/distanced-journal-challenge';
    final response = await _dio.get(
      endpoint,
      queryParameters: <String, dynamic>{
        'sessionId': onboardingSessionId,
        'lang': lang == 'en' ? 'en' : 'sr',
      },
    );
    return OnboardingDistancedJournalChallengeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OnboardingDistancedJournalExerciseDto> startDistancedJournal({
    required String onboardingSessionId,
    required String challengeId,
  }) async {
    const endpoint = '/onboarding/session/hook/distanced-journal/start';
    final response = await _dio.post(
      endpoint,
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'challengeId': challengeId,
      },
    );
    return OnboardingDistancedJournalExerciseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> submitDistancedJournal({
    required String onboardingSessionId,
    required String exerciseId,
    required DateTime sessionDate,
    required String mainAnswer,
    required String followUpAnswer,
  }) async {
    const endpoint = '/onboarding/session/hook/distanced-journal/submit';
    await _dio.post(
      endpoint,
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'exerciseId': exerciseId,
        'sessionDate': sessionDate.toUtc().toIso8601String(),
        'mainAnswer': mainAnswer,
        'followUpAnswer': followUpAnswer,
        'reflection': null,
      },
    );
  }

  Future<PerspectiveScenarioPromptDto> getPerspectiveScenarioChallenge({
    required String onboardingSessionId,
    required String lang,
  }) async {
    const endpoint = '/onboarding/session/hook/perspective-scenario-challenge';
    final response = await _dio.get(
      endpoint,
      queryParameters: <String, dynamic>{
        'sessionId': onboardingSessionId,
        'lang': lang == 'en' ? 'en' : 'sr',
      },
    );
    return PerspectiveScenarioPromptDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PerspectiveScenarioExerciseDto> startPerspectiveScenario({
    required String onboardingSessionId,
    required String challengeId,
  }) async {
    const endpoint = '/onboarding/session/hook/perspective-scenario/start';
    final response = await _dio.post(
      endpoint,
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'challengeId': challengeId,
      },
    );
    return PerspectiveScenarioExerciseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OnboardingPerspectiveAnswerRevealResponse> answerPerspectiveAndReveal({
    required String onboardingSessionId,
    required String exerciseId,
    required String questionId,
    required String answerText,
    required String lang,
  }) async {
    const endpoint = '/onboarding/session/hook/perspective-scenario/answer-and-reveal';
    final response = await _dio.post(
      endpoint,
      queryParameters: <String, dynamic>{'lang': lang == 'en' ? 'en' : 'sr'},
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'exerciseId': exerciseId,
        'questionId': questionId,
        'answerText': answerText,
      },
    );

    final raw = response.data;
    if (kDebugMode) {
      debugPrint('[Onboarding][Perspective] answer-and-reveal raw=$raw');
    }

    if (raw is Map<String, dynamic>) {
      final nested = raw['data'];
      if (nested is Map<String, dynamic>) {
        return OnboardingPerspectiveAnswerRevealResponse.fromJson(nested);
      }
      return OnboardingPerspectiveAnswerRevealResponse.fromJson(raw);
    }

    throw StateError('Unexpected answer-and-reveal response type: ${raw.runtimeType}');
  }

  Future<void> submitPerspectiveScenario({
    required String onboardingSessionId,
    required String exerciseId,
    required List<Map<String, String>> answers,
    required String lang,
  }) async {
    const endpoint = '/onboarding/session/hook/perspective-scenario/submit';
    await _dio.post(
      endpoint,
      queryParameters: <String, dynamic>{'lang': lang == 'en' ? 'en' : 'sr'},
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'exerciseId': exerciseId,
        'answers': answers,
      },
    );
  }
}
