class OnboardingSessionStartResponse {
  final String onboardingSessionId;
  final DateTime expiresAt;

  const OnboardingSessionStartResponse({
    required this.onboardingSessionId,
    required this.expiresAt,
  });

  factory OnboardingSessionStartResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingSessionStartResponse(
      onboardingSessionId: (json['onboardingSessionId'] as String?) ?? '',
      expiresAt: DateTime.parse((json['expiresAt'] as String?) ?? ''),
    );
  }
}

