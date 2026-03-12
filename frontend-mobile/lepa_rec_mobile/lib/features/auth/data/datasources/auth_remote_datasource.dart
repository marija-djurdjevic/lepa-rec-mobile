import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response.dart';
import '../models/google_login_request.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<AuthResponse> googleLogin(String idToken) async {
    final request = GoogleLoginRequest(idToken: idToken);
    const endpoint = '/auth/google-login';
    final fullUrl = '${ApiClient.dio.options.baseUrl}$endpoint';
    debugPrint('🔐 LOGIN REQUEST - POST $fullUrl');

    final response = await _dio.post(
      endpoint,
      data: request.toJson(),
    );

    debugPrint('🔐 LOGIN RESPONSE - status: ${response.statusCode}');
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> refresh(String refreshToken) async {
  const endpoint = '/auth/refresh';
  final fullUrl = '${ApiClient.dio.options.baseUrl}$endpoint';
  debugPrint('🔄 REFRESH TOKEN REQUEST - POST $fullUrl');

  final response = await _dio.post(
    endpoint,
    data: {'refreshToken': refreshToken},
  );

  debugPrint('🔄 REFRESH TOKEN RESPONSE - status: ${response.statusCode}');
  return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

}

