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
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';

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
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';
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
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';

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
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';

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
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';

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
    final fullUrl = '${ApiClient.dio.options.baseUrl}$path';

    try {
      final response = await ApiClient.dio.post(path);

      final dto =
          DailySessionStateDto.fromJson(response.data as Map<String, dynamic>);
     
      return dto;
    } catch (e) {
      rethrow;
    }
  }
}