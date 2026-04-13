class CompletePrimerDto {
  final bool isSkipped;
  final List<String>? presentedStatementIds;
  final String? selectedStatementId;
  final String? growthMessageId;

  CompletePrimerDto({
    required this.isSkipped,
    this.presentedStatementIds,
    this.selectedStatementId,
    this.growthMessageId,
  });

  factory CompletePrimerDto.fromJson(Map<String, dynamic> json) {
    return CompletePrimerDto(
      isSkipped: json['isSkipped'] as bool? ?? false,
      presentedStatementIds: List<String>.from(
        json['presentedStatementIds'] as List? ?? [],
      ),
      selectedStatementId: json['selectedStatementId'] as String?,
      growthMessageId: json['growthMessageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'isSkipped': isSkipped,
    'presentedStatementIds': presentedStatementIds,
    'selectedStatementId': selectedStatementId,
    'growthMessageId': growthMessageId,
  };
}
