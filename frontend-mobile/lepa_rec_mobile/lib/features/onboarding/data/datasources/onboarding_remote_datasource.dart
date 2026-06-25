import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lepa_rec_mobile/features/sessions/data/dtos/perspective_scenario_exercise_dto.dart';
import 'package:lepa_rec_mobile/features/sessions/data/dtos/perspective_scenario_prompt_dto.dart';

import '../../../../core/network/api_client.dart';
import '../dtos/onboarding_distanced_journal_challenge_dto.dart';
import '../dtos/onboarding_distanced_journal_exercise_dto.dart';
import '../dtos/onboarding_distanced_journal_submit_response.dart';
import '../dtos/onboarding_perspective_answer_reveal_response.dart';
import '../dtos/onboarding_session_start_response.dart';

class OnboardingRemoteDataSource {
  final Dio _dio;

  OnboardingRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<OnboardingSessionStartResponse> startSession() async {
    const endpoint = '/onboarding/session/start';
    final response = await _dio.post(endpoint, data: <String, dynamic>{});
    return OnboardingSessionStartResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
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
    return OnboardingDistancedJournalChallengeDto.fromJson(
      response.data as Map<String, dynamic>,
    );
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
    return OnboardingDistancedJournalExerciseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<OnboardingDistancedJournalSubmitResponse> submitDistancedJournal({
    required String onboardingSessionId,
    required String exerciseId,
    required DateTime sessionDate,
    required String mainAnswer,
    required String followUpAnswer,
  }) async {
    const endpoint = '/onboarding/session/hook/distanced-journal/submit';
    final response = await _dio.post(
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
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      return OnboardingDistancedJournalSubmitResponse.fromJson(raw);
    }
    return const OnboardingDistancedJournalSubmitResponse(
      generatedReflectionQuestion: null,
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
    return PerspectiveScenarioPromptDto.fromJson(
      response.data as Map<String, dynamic>,
    );
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
    return PerspectiveScenarioExerciseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<OnboardingPerspectiveAnswerRevealResponse> answerPerspectiveAndReveal({
    required String onboardingSessionId,
    required String exerciseId,
    required String questionId,
    required String answerText,
    required String idempotencyKey,
    required String lang,
  }) async {
    const endpoint =
        '/onboarding/session/hook/perspective-scenario/answer-and-reveal';
    final response = await _dio.post(
      endpoint,
      queryParameters: <String, dynamic>{'lang': lang == 'en' ? 'en' : 'sr'},
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'exerciseId': exerciseId,
        'questionId': questionId,
        'answerText': answerText,
        'idempotencyKey': idempotencyKey,
      },
    );

    final raw = response.data;
    if (kDebugMode) {
      debugPrint('[Onboarding][Perspective] answer-and-reveal raw=$raw');
    }

    if (raw is Map<String, dynamic>) {
      final dto = _parsePerspectiveAnswerRevealResponse(raw);
      if (kDebugMode) {
        final gradeData = _unwrapPerspectiveAnswerRevealPayload(raw);
        debugPrint(
          '[OnboardingPerspective][Remote][AnswerGrade] '
          'status=${dto.status} '
          'grade=${gradeData['grade'] ?? '-'} '
          'issues=${gradeData['issues'] ?? const []} '
          'strengths=${gradeData['strengths'] ?? const []} '
          'feedback=${dto.feedback ?? '-'}',
        );
      }
      return dto;
    }

    throw StateError(
      'Unexpected answer-and-reveal response type: ${raw.runtimeType}',
    );
  }

  Future<OnboardingPerspectiveAnswerRevealResponse>
  answerPerspectiveAndRevealStream({
    required String onboardingSessionId,
    required String exerciseId,
    required String questionId,
    required String answerText,
    required String idempotencyKey,
    required String lang,
    required void Function(String guideText) onGuideTextChanged,
  }) async {
    const endpoint =
        '/onboarding/session/hook/perspective-scenario/answer-and-reveal/stream';
    final response = await _dio.post<ResponseBody>(
      endpoint,
      queryParameters: <String, dynamic>{'lang': lang == 'en' ? 'en' : 'sr'},
      data: <String, dynamic>{
        'onboardingSessionId': onboardingSessionId,
        'exerciseId': exerciseId,
        'questionId': questionId,
        'answerText': answerText,
        'idempotencyKey': idempotencyKey,
      },
      options: Options(
        headers: {'Accept': 'text/event-stream'},
        responseType: ResponseType.stream,
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    final stream = response.data?.stream;
    if (stream == null) {
      throw StateError('Onboarding perspective stream did not return a body.');
    }

    return _parsePerspectiveAnswerRevealStream(
      stream.cast<List<int>>().transform(utf8.decoder),
      onGuideTextChanged: onGuideTextChanged,
    );
  }

  Future<OnboardingPerspectiveAnswerRevealResponse>
  _parsePerspectiveAnswerRevealStream(
    Stream<String> stream, {
    required void Function(String guideText) onGuideTextChanged,
  }) async {
    var buffer = '';
    var guideText = '';

    await for (final chunk in stream) {
      buffer += chunk.replaceAll('\r\n', '\n');
      final rawEvents = buffer.split('\n\n');
      buffer = rawEvents.removeLast();

      for (final rawEvent in rawEvents) {
        final parsedEvent = _parseSseEvent(rawEvent);
        if (parsedEvent == null) continue;

        final data = jsonDecode(parsedEvent.data) as Map<String, dynamic>;
        switch (parsedEvent.name) {
          case 'grade':
            if (kDebugMode) {
              debugPrint(
                '[OnboardingPerspective][Remote][Grade] ${jsonEncode(data)}',
              );
            }
            break;
          case 'guide_chunk':
            final chunkText = data['chunk'] as String? ?? '';
            if (chunkText.isEmpty) break;
            guideText += chunkText;
            onGuideTextChanged(guideText);
            break;
          case 'final':
            final result = data['result'] is Map<String, dynamic>
                ? data['result'] as Map<String, dynamic>
                : data;
            final dto = _parsePerspectiveAnswerRevealResponse(result);
            if (kDebugMode) {
              final gradeData = _unwrapPerspectiveAnswerRevealPayload(result);
              debugPrint(
                '[OnboardingPerspective][Remote][FinalGrade] '
                'status=${dto.status} '
                'grade=${gradeData['grade'] ?? '-'} '
                'issues=${gradeData['issues'] ?? const []} '
                'strengths=${gradeData['strengths'] ?? const []} '
                'feedback=${dto.feedback ?? '-'}',
              );
            }
            return dto;
          case 'error':
            throw StateError('Onboarding perspective streaming error.');
          default:
            break;
        }
      }
    }

    throw StateError(
      'Onboarding perspective stream ended before final result.',
    );
  }

  OnboardingPerspectiveAnswerRevealResponse
  _parsePerspectiveAnswerRevealResponse(Map<String, dynamic> raw) {
    return OnboardingPerspectiveAnswerRevealResponse.fromJson(
      _unwrapPerspectiveAnswerRevealPayload(raw),
    );
  }

  Map<String, dynamic> _unwrapPerspectiveAnswerRevealPayload(
    Map<String, dynamic> raw,
  ) {
    final nested = raw['data'];
    if (nested is Map<String, dynamic>) return nested;
    return raw;
  }

  _SseEvent? _parseSseEvent(String rawEvent) {
    String? eventName;
    final dataLines = <String>[];

    for (final line in rawEvent.split('\n')) {
      if (line.startsWith('event:')) {
        eventName = line.substring('event:'.length).trim();
      } else if (line.startsWith('data:')) {
        dataLines.add(line.substring('data:'.length).trimLeft());
      }
    }

    if (eventName == null || dataLines.isEmpty) {
      return null;
    }

    return _SseEvent(eventName, dataLines.join('\n'));
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

class _SseEvent {
  final String name;
  final String data;

  const _SseEvent(this.name, this.data);
}
