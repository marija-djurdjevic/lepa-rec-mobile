import '../../../../core/config/api_environment.dart';

class DistancedJournalExerciseDto {
  final String id;
  final String userId;
  final String challengeId;
  final String? mainAnswer;
  final String? followUpAnswer;
  final String? reflection;
  final List<String> photoUrls;
  final DateTime? submittedAt;
  final bool isCompleted;

  DistancedJournalExerciseDto({
    required this.id,
    required this.userId,
    required this.challengeId,
    this.mainAnswer,
    this.followUpAnswer,
    this.reflection,
    this.photoUrls = const [],
    this.submittedAt,
    required this.isCompleted,
  });

  factory DistancedJournalExerciseDto.fromJson(Map<String, dynamic> json) {
    return DistancedJournalExerciseDto(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      challengeId: json['challengeId'] as String? ?? '',
      mainAnswer: json['mainAnswer'] as String?,
      followUpAnswer: json['followUpAnswer'] as String?,
      reflection: json['reflection'] as String?,
      photoUrls:
          (json['photoUrls'] as List<dynamic>? ?? const [])
              .map((value) => _normalizePhotoUrl(value.toString()))
              .toList(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static String _normalizePhotoUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final base = Uri.parse(ApiEnvironment.baseUrl);
    final origin =
        '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }
    return '$origin/$trimmed';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'challengeId': challengeId,
    'mainAnswer': mainAnswer,
    'followUpAnswer': followUpAnswer,
    'reflection': reflection,
    'photoUrls': photoUrls,
    'submittedAt': submittedAt?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  @override
  String toString() =>
      'DistancedJournalExerciseDto(id: $id, userId: $userId, '
      'challengeId: $challengeId, isCompleted: $isCompleted)';
}
