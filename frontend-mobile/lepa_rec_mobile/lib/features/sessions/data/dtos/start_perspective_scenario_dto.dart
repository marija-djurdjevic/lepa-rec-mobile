class StartPerspectiveScenarioDto {
  final String challengeId;

  StartPerspectiveScenarioDto({required this.challengeId});

  Map<String, dynamic> toJson() => {'challengeId': challengeId};
}
