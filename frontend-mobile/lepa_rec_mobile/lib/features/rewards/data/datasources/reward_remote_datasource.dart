import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../sessions/data/dtos/reward_progress_dto.dart';

class RewardRemoteDataSource {
  final Dio _dio;

  RewardRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<RewardProgressDto> saveReward(String rewardProgressId) async {
    final endpoint = '/Rewards/$rewardProgressId/save';
    final response = await _dio.post(endpoint);
    return RewardProgressDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RewardProgressDto>> getGallery() async {
    const endpoint = '/Rewards/gallery';
    final response = await _dio.get(endpoint);
    final data = response.data as Map<String, dynamic>;
    final rewards = data['completedRewards'] as List<dynamic>? ?? [];
    return rewards
        .map((item) => RewardProgressDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
