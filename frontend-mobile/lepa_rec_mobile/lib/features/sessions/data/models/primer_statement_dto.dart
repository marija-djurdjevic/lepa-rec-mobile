import 'package:flutter/foundation.dart';

class PrimerStatementDto {
  final String statementId;
  final String text;

  PrimerStatementDto({
    required this.statementId,
    required this.text,
  });

  factory PrimerStatementDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📝 PrimerStatementDto.fromJson() - parsing statement');
    debugPrint('📝 Raw JSON: $json');

    try {
      final statementId = json['statementId'] as String;
      debugPrint('📝 Parsed statementId: $statementId');

      final text = json['text'] as String;
      debugPrint('📝 Parsed text: $text');

      debugPrint('✅ PrimerStatementDto.fromJson() parsing completed successfully');

      return PrimerStatementDto(
        statementId: statementId,
        text: text,
      );
    } catch (e) {
      debugPrint('❌ PrimerStatementDto.fromJson() parsing failed: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'statementId': statementId,
        'text': text,
      };
}
