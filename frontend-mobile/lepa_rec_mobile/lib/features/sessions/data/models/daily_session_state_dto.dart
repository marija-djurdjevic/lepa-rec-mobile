import 'package:flutter/foundation.dart';

class DailySessionStateDto {
  final String sessionId;
  final String status;
  final bool requiresPrimer;
  final bool primerCompleted;
  final bool primerSkipped;
  final int completedExercisesCount;

  DailySessionStateDto({
    required this.sessionId,
    required this.status,
    required this.requiresPrimer,
    required this.primerCompleted,
    required this.primerSkipped,
    required this.completedExercisesCount,
  });

  factory DailySessionStateDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📄 DailySessionStateDto.fromJson() - parsing response');
    debugPrint('📄 Raw JSON keys: ${json.keys.toList()}');
    debugPrint('📄 Raw JSON: $json');

    try {
      final sessionId = json['sessionId'] as String;
      debugPrint('📄 Parsed sessionId: $sessionId');

      final status = json['status'] as String;
      debugPrint('📄 Parsed status: $status');

      final requiresPrimer = json['requiresPrimer'] as bool? ?? false;
      debugPrint('📄 Parsed requiresPrimer: $requiresPrimer');

      final primerCompleted = json['primerCompleted'] as bool? ?? false;
      debugPrint('📄 Parsed primerCompleted: $primerCompleted');

      final primerSkipped = json['primerSkipped'] as bool? ?? false;
      debugPrint('📄 Parsed primerSkipped: $primerSkipped');

      final completedExercisesCount =
          json['completedExercisesCount'] as int? ?? 0;
      debugPrint('📄 Parsed completedExercisesCount: $completedExercisesCount');

      debugPrint('✅ DailySessionStateDto.fromJson() parsing completed successfully');

      return DailySessionStateDto(
        sessionId: sessionId,
        status: status,
        requiresPrimer: requiresPrimer,
        primerCompleted: primerCompleted,
        primerSkipped: primerSkipped,
        completedExercisesCount: completedExercisesCount,
      );
    } catch (e) {
      debugPrint('❌ DailySessionStateDto.fromJson() parsing failed: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'status': status,
        'requiresPrimer': requiresPrimer,
        'primerCompleted': primerCompleted,
        'primerSkipped': primerSkipped,
        'completedExercisesCount': completedExercisesCount,
      };
}