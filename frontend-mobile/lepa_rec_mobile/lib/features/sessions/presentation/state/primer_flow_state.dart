class PrimerFlowState {
  final List<String> presentedStatementIds;
  final String? selectedStatementId;
  final String? growthMessageId;

  PrimerFlowState({
    this.presentedStatementIds = const [],
    this.selectedStatementId,
    this.growthMessageId,
  });

  PrimerFlowState copyWith({
    List<String>? presentedStatementIds,
    String? selectedStatementId,
    String? growthMessageId,
  }) {
    return PrimerFlowState(
      presentedStatementIds:
          presentedStatementIds ?? this.presentedStatementIds,
      selectedStatementId: selectedStatementId ?? this.selectedStatementId,
      growthMessageId: growthMessageId ?? this.growthMessageId,
    );
  }

  @override
  String toString() {
    return 'PrimerFlowState(presentedStatementIds: $presentedStatementIds, '
        'selectedStatementId: $selectedStatementId, '
        'growthMessageId: $growthMessageId)';
  }
}
