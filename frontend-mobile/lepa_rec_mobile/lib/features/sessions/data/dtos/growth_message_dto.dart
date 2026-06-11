class GrowthMessageDto {
  final String messageId;
  final String text;
  final String? prefix;
  final String? description;

  GrowthMessageDto({
    required this.messageId,
    required this.text,
    this.prefix,
    this.description,
  });

  factory GrowthMessageDto.fromJson(Map<String, dynamic> json) {
    try {
      final messageId = json['messageId'] as String;
      final text = json['text'] as String;
      final prefix = (json['prefix'] ??
              json['skillPrefix'] ??
              json['displayPrefix']) as String?;
      final description = (json['description'] ??
              json['skillDescription'] ??
              json['displayDescription']) as String?;

      return GrowthMessageDto(
        messageId: messageId,
        text: text,
        prefix: prefix,
        description: description,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'text': text,
    'prefix': prefix,
    'description': description,
  };
}
