class PrimerStatementDto {
  final String statementId;
  final String text;

  PrimerStatementDto({required this.statementId, required this.text});

  factory PrimerStatementDto.fromJson(Map<String, dynamic> json) {
    try {
      final statementId = json['statementId'] as String;

      final text = json['text'] as String;

      return PrimerStatementDto(statementId: statementId, text: text);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {'statementId': statementId, 'text': text};
}
