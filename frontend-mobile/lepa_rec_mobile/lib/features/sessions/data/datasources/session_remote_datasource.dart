import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/complete_primer_dto.dart';
import '../models/daily_session_state_dto.dart';
import '../models/growth_message_dto.dart';
import '../models/primer_statement_dto.dart';

class SessionRemoteDataSource {
  static const String _baseEndpoint = '/sessions';

  Future<DailySessionStateDto> getTodaySession() async {
    const path = '$_baseEndpoint/today';
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';
    debugPrint('📡 SESSION START REQUEST - GET $fullUrl');

    try {
      final response = await ApiClient.dio.get(path);

      debugPrint('📡 SESSION START RESPONSE - status: ${response.statusCode}');
      debugPrint('📡 SESSION START RAW RESPONSE: ${response.data}');

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
      debugPrint(
        '📡 SESSION START PARSED DTO - sessionId: ${dto.sessionId}, '
        'primerCompleted: ${dto.primerCompleted}, '
        'requiresPrimer: ${dto.requiresPrimer}',
      );
      return dto;
    } catch (e) {
      debugPrint('❌ SESSION START PARSING ERROR: $e');
      rethrow;
    }
  }

  Future<DailySessionStateDto> completePrimer() async {
    const path = '$_baseEndpoint/primer/complete';
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';
    debugPrint('📡 PRIMER COMPLETE REQUEST - POST $fullUrl');

    try {
      final response = await ApiClient.dio.post(
        path,
        data: {},
      );

      debugPrint('📡 PRIMER COMPLETE RESPONSE - status: ${response.statusCode}');
      debugPrint('📡 PRIMER COMPLETE RAW RESPONSE: ${response.data}');

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
      debugPrint(
        '📡 PRIMER COMPLETE PARSED DTO - '
        'primerCompleted: ${dto.primerCompleted}, '
        'primerSkipped: ${dto.primerSkipped}, '
        'status: ${dto.status}',
      );
      return dto;
    } catch (e) {
      debugPrint('❌ PRIMER COMPLETE PARSING ERROR: $e');
      rethrow;
    }
  }

  Future<void> completePrimerWithData(CompletePrimerDto primerData) async {
    const path = '$_baseEndpoint/primer/complete';
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';
    debugPrint('📡 PRIMER COMPLETE WITH DATA REQUEST - POST $fullUrl');
    debugPrint('📡 Request body: ${primerData.toJson()}');

    try {
      final response = await ApiClient.dio.post(
        path,
        data: primerData.toJson(),
      );

      debugPrint(
        '📡 PRIMER COMPLETE WITH DATA RESPONSE - status: ${response.statusCode}',
      );
      debugPrint('📡 PRIMER COMPLETE WITH DATA RAW RESPONSE: ${response.data}');

      debugPrint('✅ Primer completed successfully with data');
    } catch (e) {
      debugPrint('❌ PRIMER COMPLETE WITH DATA ERROR: $e');
      rethrow;
    }
  }

  Future<List<PrimerStatementDto>> getRandomPrimerStatements() async {
    const path = '/practice/affirmation-values/random-statements';
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';
    debugPrint('📡 GET PRIMER STATEMENTS REQUEST - GET $fullUrl');

    try {
      final response = await ApiClient.dio.get(path);

      debugPrint(
        '📡 GET PRIMER STATEMENTS RESPONSE - status: ${response.statusCode}',
      );
      debugPrint('📡 GET PRIMER STATEMENTS RAW RESPONSE: ${response.data}');

      final List<dynamic> jsonList = response.data as List<dynamic>;
      final statements = jsonList
          .map((json) =>
              PrimerStatementDto.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Parsed ${statements.length} primer statements');
      for (var stmt in statements) {
        debugPrint('   - ${stmt.statementId}: ${stmt.text}');
      }

      return statements;
    } catch (e) {
      debugPrint('❌ GET PRIMER STATEMENTS ERROR: $e');
      rethrow;
    }
  }

  Future<GrowthMessageDto> getRandomGrowthMessage() async {
    const path = '/practice/growth-messages/random';
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';
    debugPrint('📡 GET GROWTH MESSAGE REQUEST - GET $fullUrl');

    try {
      final response = await ApiClient.dio.get(path);

      debugPrint(
        '📡 GET GROWTH MESSAGE RESPONSE - status: ${response.statusCode}',
      );
      debugPrint('📡 GET GROWTH MESSAGE RAW RESPONSE: ${response.data}');

      final message =
          GrowthMessageDto.fromJson(response.data as Map<String, dynamic>);

      debugPrint('✅ Growth message parsed - ID: ${message.messageId}');
      debugPrint('   Text: ${message.text}');

      return message;
    } catch (e) {
      debugPrint('❌ GET GROWTH MESSAGE ERROR: $e');
      rethrow;
    }
  }

  Future<DailySessionStateDto> recordExercise(String exerciseName) async {
    const path = '$_baseEndpoint/exercises/record';
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';
    debugPrint(
      '📡 EXERCISE RECORD REQUEST - POST $fullUrl (exerciseName: $exerciseName)',
    );

    try {
      final response = await ApiClient.dio.post(
        path,
        data: {'exerciseName': exerciseName},
      );

      debugPrint('📡 EXERCISE RECORD RESPONSE - status: ${response.statusCode}');
      debugPrint('📡 EXERCISE RECORD RAW RESPONSE: ${response.data}');

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
      debugPrint(
        '📡 EXERCISE RECORD PARSED DTO - completedExercisesCount: ${dto.completedExercisesCount}, '
        'status: ${dto.status}',
      );
      return dto;
    } catch (e) {
      debugPrint('❌ EXERCISE RECORD PARSING ERROR: $e');
      rethrow;
    }
  }

  Future<DailySessionStateDto> completeSession() async {
    const path = '$_baseEndpoint/complete';
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';
    debugPrint('📡 SESSION COMPLETE REQUEST - POST $fullUrl');

    try {
      final response = await ApiClient.dio.post(path);

      debugPrint('📡 SESSION COMPLETE RESPONSE - status: ${response.statusCode}');
      debugPrint('📡 SESSION COMPLETE RAW RESPONSE: ${response.data}');

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
      debugPrint(
        '📡 SESSION COMPLETE PARSED DTO - status: ${dto.status}, '
        'primerCompleted: ${dto.primerCompleted}, '
        'completedExercisesCount: ${dto.completedExercisesCount}',
      );
      return dto;
    } catch (e) {
      debugPrint('❌ SESSION COMPLETE PARSING ERROR: $e');
      rethrow;
    }
  }
}