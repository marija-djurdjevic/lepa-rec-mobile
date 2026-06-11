import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../dtos/auth_response.dart';
import '../dtos/google_login_request.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<AuthResponse> googleLogin(String idToken) async {
    final request = GoogleLoginRequest(idToken: idToken);
    const endpoint = '/auth/google-login';

    final response = await _dio.post(
      endpoint,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    const endpoint = '/auth/login';

    final response = await _dio.post(
      endpoint,
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> refresh(String refreshToken) async {
  const endpoint = '/auth/refresh';

  final response = await _dio.post(
    endpoint,
    data: {'refreshToken': refreshToken},
  );

  return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> registerWithOnboarding({
    required String email,
    required String password,
    required String onboardingSessionId,
    required String firstName,
    required String lastName,
    required bool notificationEnabled,
    required String? notificationTimeLocal,
    required String timeZoneId,
  }) async {
    const endpoint = '/auth/register-with-onboarding';

    final response = await _dio.post(
      endpoint,
      data: <String, dynamic>{
        'email': email,
        'password': password,
        'onboardingSessionId': onboardingSessionId,
        'profile': <String, dynamic>{
          'firstName': firstName,
          'lastName': lastName,
          'notificationEnabled': notificationEnabled,
          'notificationTimeLocal': notificationTimeLocal,
          'timeZoneId': timeZoneId,
        },
      },
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

}

