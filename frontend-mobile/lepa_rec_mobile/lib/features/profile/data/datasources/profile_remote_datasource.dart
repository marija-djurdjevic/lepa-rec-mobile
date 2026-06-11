import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../dtos/profile_me_dto.dart';

class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<ProfileMeDto> getMe() async {
    const endpoint = '/profile/me';
    final response = await _dio.get(endpoint);
    return ProfileMeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProfileMeDto> updateMe({
    required String firstName,
    required String lastName,
    required String preferredLanguage,
    required bool notificationEnabled,
    required String? notificationTimeLocal,
    required String? timeZoneId,
  }) async {
    const endpoint = '/profile/me';
    final response = await _dio.put(
      endpoint,
      data: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'preferredLanguage': preferredLanguage,
        'notificationEnabled': notificationEnabled,
        'notificationTimeLocal': notificationEnabled
            ? notificationTimeLocal
            : null,
        'timeZoneId': notificationEnabled ? timeZoneId : null,
      },
    );

    return ProfileMeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {
    const endpoint = '/profile/push-token';
    await _dio.post(
      endpoint,
      data: <String, dynamic>{'token': token, 'platform': platform},
    );
  }

  Future<void> unregisterPushToken({required String token}) async {
    const endpoint = '/profile/push-token';
    await _dio.delete(endpoint, data: <String, dynamic>{'token': token});
  }

  Future<void> deleteAccount() async {
    const endpoint = '/account';
    await _dio.delete<void>(endpoint);
  }
}
