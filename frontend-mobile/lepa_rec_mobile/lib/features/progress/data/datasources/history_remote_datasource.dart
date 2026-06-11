import '../../../../core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import '../../../sessions/data/dtos/distanced_journal_challenge_dto.dart';
import '../../../sessions/data/dtos/distanced_journal_exercise_dto.dart';
import '../../../sessions/data/dtos/perspective_scenario_exercise_dto.dart';
import '../dtos/perspective_scenario_challenge_dto.dart';

class HistoryRemoteDataSource {
  String _normalizeLang(String? lang) {
    return lang == 'en' ? 'en' : 'sr';
  }

  Future<List<DistancedJournalExerciseDto>> getDistancedJournalExercises({
    String? lang,
  }) async {
    const path = '/DistancedJournals/mine';
    final response = await ApiClient.dio.get(
      path,
      queryParameters: {'lang': _normalizeLang(lang)},
    );
    final list = _asList(response.data);
    debugPrint('[History][API] GET $path lang=${_normalizeLang(lang)} rawCount=${list.length} raw=${response.data}');
    final exercises = list
        .map(
          (item) => DistancedJournalExerciseDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
    debugPrint('[History][API] Distanced parsedCount=${exercises.length} completed=${exercises.where((e) => e.isCompleted).length}');
    return exercises;
  }

  Future<List<DistancedJournalChallengeDto>> getDistancedJournalChallenges({
    String? lang,
  }) async {
    const path = '/DistancedJournals/challenges';
    final response = await ApiClient.dio.get(
      path,
      queryParameters: {'lang': _normalizeLang(lang)},
    );
    final list = _asList(response.data);
    return list
        .map(
          (item) => DistancedJournalChallengeDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<PerspectiveScenarioExerciseDto>> getPerspectiveScenarioExercises({
    String? lang,
  }) async {
    const path = '/PerspectiveScenarios/mine';
    final response = await ApiClient.dio.get(
      path,
      queryParameters: {'lang': _normalizeLang(lang)},
    );
    final list = _asList(response.data);
    debugPrint('[History][API] GET $path lang=${_normalizeLang(lang)} rawCount=${list.length} raw=${response.data}');
    final exercises = list
        .map(
          (item) => PerspectiveScenarioExerciseDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
    debugPrint('[History][API] Perspective parsedCount=${exercises.length} completed=${exercises.where((e) => e.isCompleted).length}');
    return exercises;
  }

  Future<List<PerspectiveScenarioChallengeDto>>
      getPerspectiveScenarioChallenges({
    String? lang,
  }) async {
    const path = '/PerspectiveScenarios/challenges';
    final response = await ApiClient.dio.get(
      path,
      queryParameters: {'lang': _normalizeLang(lang)},
    );
    final list = _asList(response.data);
    return list
        .map(
          (item) => PerspectiveScenarioChallengeDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    return const [];
  }
}
