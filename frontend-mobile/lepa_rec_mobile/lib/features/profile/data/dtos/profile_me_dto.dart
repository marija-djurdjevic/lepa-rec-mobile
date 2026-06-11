class ProfileMeDto {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String preferredLanguage;
  final bool notificationEnabled;
  final String? notificationTimeLocal;
  final String? timeZoneId;
  final bool onboardingCompleted;

  const ProfileMeDto({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.preferredLanguage,
    required this.notificationEnabled,
    required this.notificationTimeLocal,
    required this.timeZoneId,
    required this.onboardingCompleted,
  });

  factory ProfileMeDto.fromJson(Map<String, dynamic> json) {
    return ProfileMeDto(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'sr',
      notificationEnabled: json['notificationEnabled'] as bool? ?? false,
      notificationTimeLocal: json['notificationTimeLocal'] as String?,
      timeZoneId: json['timeZoneId'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }
}

