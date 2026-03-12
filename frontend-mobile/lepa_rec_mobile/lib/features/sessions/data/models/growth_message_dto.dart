import 'package:flutter/foundation.dart';

class GrowthMessageDto {
  final String messageId;
  final String text;

  GrowthMessageDto({
    required this.messageId,
    required this.text,
  });

  factory GrowthMessageDto.fromJson(Map<String, dynamic> json) {

    try {
      final messageId = json['messageId'] as String;

      final text = json['text'] as String;

      return GrowthMessageDto(
        messageId: messageId,
        text: text,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'text': text,
      };
}
