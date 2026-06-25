import '../../../sessions/data/dtos/reward_progress_dto.dart';
import '../datasources/reward_remote_datasource.dart';

class RewardRepository {
  final RewardRemoteDataSource _remote;

  RewardRepository({RewardRemoteDataSource? remote})
    : _remote = remote ?? RewardRemoteDataSource();

  Future<RewardProgressDto> saveReward(String rewardProgressId) =>
      _remote.saveReward(rewardProgressId);

  Future<List<RewardProgressDto>> getGallery() => _remote.getGallery();
}
