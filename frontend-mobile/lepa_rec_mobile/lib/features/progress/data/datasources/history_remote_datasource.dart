import '../../../../core/network/api_client.dart';
import '../../../sessions/data/dtos/distanced_journal_challenge_dto.dart';
import '../../../sessions/data/dtos/distanced_journal_exercise_dto.dart';
import '../../../sessions/data/dtos/perspective_scenario_exercise_dto.dart';
import '../dtos/perspective_scenario_challenge_dto.dart';

class HistoryRemoteDataSource {
  Future<List<DistancedJournalExerciseDto>> getDistancedJournalExercises() async {
    const path = '/DistancedJournals/mine';
    final response = await ApiClient.dio.get(path);
    final list = _asList(response.data);
    final exercises = list
        .map(
          (item) => DistancedJournalExerciseDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
    return exercises;
  }

  Future<List<DistancedJournalChallengeDto>> getDistancedJournalChallenges() async {
    const path = '/DistancedJournals/challenges';
    final response = await ApiClient.dio.get(path);
    final list = _asList(response.data);
    return list
        .map(
          (item) => DistancedJournalChallengeDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<PerspectiveScenarioExerciseDto>> getPerspectiveScenarioExercises() async {
    const path = '/PerspectiveScenarios/mine';
    final response = await ApiClient.dio.get(path);
    final list = _asList(response.data);
    return list
        .map(
          (item) => PerspectiveScenarioExerciseDto.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<PerspectiveScenarioChallengeDto>> getPerspectiveScenarioChallenges() async {
    const path = '/PerspectiveScenarios/challenges';
    final response = await ApiClient.dio.get(path);
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
