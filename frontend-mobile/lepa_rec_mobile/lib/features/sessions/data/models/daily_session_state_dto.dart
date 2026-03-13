
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

    try {
      final sessionId = json['sessionId'] as String;

      final status = json['status'] as String;

      final requiresPrimer = json['requiresPrimer'] as bool? ?? false;

      final primerCompleted = json['primerCompleted'] as bool? ?? false;

      final primerSkipped = json['primerSkipped'] as bool? ?? false;

      final completedExercisesCount =
          json['completedExercisesCount'] as int? ?? 0;


      return DailySessionStateDto(
        sessionId: sessionId,
        status: status,
        requiresPrimer: requiresPrimer,
        primerCompleted: primerCompleted,
        primerSkipped: primerSkipped,
        completedExercisesCount: completedExercisesCount,
      );
    } catch (e) {
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