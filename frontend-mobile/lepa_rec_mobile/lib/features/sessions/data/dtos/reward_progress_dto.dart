class RewardProgressDto {
  final String rewardProgressId;
  final String rewardImageId;
  final String? imageUrl;
  final String assetPath;
  final int unlockedPiecesCount;
  final int? previousUnlockedPiecesCount;
  final int? newlyUnlockedPieceIndex;
  final DateTime? completedAt;
  final DateTime? savedAt;
  final bool shouldPlayUnlockAnimation;

  const RewardProgressDto({
    required this.rewardProgressId,
    required this.rewardImageId,
    this.imageUrl,
    required this.assetPath,
    required this.unlockedPiecesCount,
    this.previousUnlockedPiecesCount,
    this.newlyUnlockedPieceIndex,
    this.completedAt,
    this.savedAt,
    this.shouldPlayUnlockAnimation = false,
  });

  bool get isCompleted => unlockedPiecesCount >= 4;

  factory RewardProgressDto.fromJson(Map<String, dynamic> json) {
    return RewardProgressDto(
      rewardProgressId: json['rewardProgressId'] as String? ?? '',
      rewardImageId: json['rewardImageId'] as String? ?? '',
      imageUrl: _parseString(json['imageUrl']),
      assetPath:
          json['assetPath'] as String? ??
          json['assetUrl'] as String? ??
          json['imageUrl'] as String? ??
          '',
      unlockedPiecesCount: _clampPieces(json['unlockedPiecesCount']),
      previousUnlockedPiecesCount: _parseInt(
        json['previousUnlockedPiecesCount'],
      ),
      newlyUnlockedPieceIndex: _parseInt(json['newlyUnlockedPieceIndex']),
      completedAt: _parseDate(json['completedAt']),
      savedAt: _parseDate(json['savedAt']),
      shouldPlayUnlockAnimation:
          _parseBool(json['shouldPlayUnlockAnimation']) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'rewardProgressId': rewardProgressId,
    'rewardImageId': rewardImageId,
    'imageUrl': imageUrl,
    'assetPath': assetPath,
    'unlockedPiecesCount': unlockedPiecesCount,
    'previousUnlockedPiecesCount': previousUnlockedPiecesCount,
    'newlyUnlockedPieceIndex': newlyUnlockedPieceIndex,
    'completedAt': completedAt?.toIso8601String(),
    'savedAt': savedAt?.toIso8601String(),
    'shouldPlayUnlockAnimation': shouldPlayUnlockAnimation,
  };

  static int _clampPieces(dynamic value) {
    final parsed = _parseInt(value) ?? 0;
    if (parsed < 0) return 0;
    if (parsed > 4) return 4;
    return parsed;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
