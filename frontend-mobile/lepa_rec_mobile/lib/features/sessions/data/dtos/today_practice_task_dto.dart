import '../../../../core/constants/app_constants.dart';

class DistancedJournalReflectionPromptDto {
  final String exerciseId;
  final String challengeContent;
  final String challengeFollowUpQuestion;
  final String? previousMainAnswer;
  final String? previousFollowUpAnswer;
  final List<String> previousPhotoUrls;

  DistancedJournalReflectionPromptDto({
    required this.exerciseId,
    required this.challengeContent,
    required this.challengeFollowUpQuestion,
    this.previousMainAnswer,
    this.previousFollowUpAnswer,
    this.previousPhotoUrls = const [],
  });

  factory DistancedJournalReflectionPromptDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return DistancedJournalReflectionPromptDto(
      exerciseId: _toString(json['exerciseId']) ?? '',
      challengeContent: json['challengeContent'] as String? ?? '',
      challengeFollowUpQuestion:
          json['challengeFollowUpQuestion'] as String? ?? '',
      previousMainAnswer: json['previousMainAnswer'] as String?,
      previousFollowUpAnswer: json['previousFollowUpAnswer'] as String?,
      previousPhotoUrls:
          (json['previousPhotoUrls'] as List<dynamic>? ?? const [])
              .map((value) => _normalizePhotoUrl(value.toString()))
              .toList(),
    );
  }

  static String _normalizePhotoUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final base = Uri.parse(AppConstants.apiBaseUrl);
    final origin =
        '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }
    return '$origin/$trimmed';
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'challengeContent': challengeContent,
    'challengeFollowUpQuestion': challengeFollowUpQuestion,
    'previousMainAnswer': previousMainAnswer,
    'previousFollowUpAnswer': previousFollowUpAnswer,
    'previousPhotoUrls': previousPhotoUrls,
  };

  @override
  String toString() =>
      'DistancedJournalReflectionPromptDto(exerciseId: $exerciseId, '
      'challengeContent: $challengeContent)';
}
