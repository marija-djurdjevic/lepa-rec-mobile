import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_environment.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient._();
  static String _languageCode = 'sr';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEnvironment.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get dio => _dio;

  static void configure() {
    if (_dio.interceptors.whereType<AuthInterceptor>().isNotEmpty) return;
    _dio.interceptors.add(AuthInterceptor(_dio));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_shouldAttachLang(options.path)) {
            final qp = Map<String, dynamic>.from(options.queryParameters);
            qp.putIfAbsent('lang', () => _normalizeLanguageCode(_languageCode));
            options.queryParameters = qp;
          }
          handler.next(options);
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (_shouldLog(options.path)) {
              debugPrint('[API][REQ] ${options.method} ${options.uri}');
            }
            handler.next(options);
          },
          onResponse: (response, handler) {
            if (_shouldLog(response.requestOptions.path)) {
              debugPrint(
                '[API][RES] ${response.statusCode} '
                '${response.requestOptions.method} ${response.requestOptions.uri}',
              );
            }
            handler.next(response);
          },
          onError: (error, handler) {
            if (_shouldLog(error.requestOptions.path)) {
              final responseData = error.response?.data;
              debugPrint(
                '[API][ERR] ${error.response?.statusCode ?? '-'} '
                '${error.requestOptions.method} ${error.requestOptions.uri} '
                '${error.message} '
                'response=${responseData ?? '-'}',
              );
            }
            handler.next(error);
          },
        ),
      );
    }
  }

  static bool _shouldLog(String path) {
    final lower = path.toLowerCase();
    return lower.contains('/practice') ||
        lower.contains('/sessions') ||
        lower.contains('/distancedjournals') ||
        lower.contains('/perspectivescenarios') ||
        lower.contains('/auth') ||
        lower.contains('/onboarding');
  }

  static bool _shouldAttachLang(String path) {
    final lower = path.toLowerCase();
    return lower.contains('/practice') ||
        lower.contains('/distancedjournals') ||
        lower.contains('/perspectivescenarios');
  }

  static void setLanguageCode(String languageCode) {
    _languageCode = _normalizeLanguageCode(languageCode);
  }

  static String _normalizeLanguageCode(String? languageCode) {
    return languageCode == 'en' ? 'en' : 'sr';
  }
}
