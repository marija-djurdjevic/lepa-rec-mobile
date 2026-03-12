import 'package:flutter/foundation.dart';

class GrowthMessageDto {
  final String messageId;
  final String text;

  GrowthMessageDto({
    required this.messageId,
    required this.text,
  });

  factory GrowthMessageDto.fromJson(Map<String, dynamic> json) {
    debugPrint('💬 GrowthMessageDto.fromJson() - parsing message');
    debugPrint('💬 Raw JSON: $json');

    try {
      final messageId = json['messageId'] as String;
      debugPrint('💬 Parsed messageId: $messageId');

      final text = json['text'] as String;
      debugPrint('💬 Parsed text: $text');

      debugPrint('✅ GrowthMessageDto.fromJson() parsing completed successfully');

      return GrowthMessageDto(
        messageId: messageId,
        text: text,
      );
    } catch (e) {
      debugPrint('❌ GrowthMessageDto.fromJson() parsing failed: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'text': text,
      };
}
