import 'daily_session_state_dto.dart';
import 'reward_progress_dto.dart';

class CompleteSessionResultDto {
  final DailySessionStateDto session;
  final RewardProgressDto? currentReward;

  const CompleteSessionResultDto({
    required this.session,
    required this.currentReward,
  });

  factory CompleteSessionResultDto.fromJson(Map<String, dynamic> json) {
    final sessionJson = json['session'] is Map<String, dynamic>
        ? json['session'] as Map<String, dynamic>
        : json;
    final rewardJson = json['currentReward'] is Map<String, dynamic>
        ? json['currentReward'] as Map<String, dynamic>
        : null;

    return CompleteSessionResultDto(
      session: DailySessionStateDto.fromJson(sessionJson),
      currentReward: rewardJson != null
          ? RewardProgressDto.fromJson(rewardJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'session': session.toJson(),
    'currentReward': currentReward?.toJson(),
  };
}
