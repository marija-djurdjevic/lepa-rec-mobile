import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  AuthInterceptor(
    this._dio, {
    AuthLocalDataSource? local,
    AuthRemoteDataSource? remote,
  })  : _local = local ?? AuthLocalDataSource(),
        _remote = remote ?? AuthRemoteDataSource();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _local.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔒 AuthInterceptor - Bearer token added for ${options.method} ${options.path}');
    } else {
      debugPrint('🔒 AuthInterceptor - No access token for ${options.method} ${options.path} (request may fail with 401)');
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    debugPrint('🛑 AuthInterceptor.onError() - status: $statusCode, path: ${err.requestOptions.path}');

    if (statusCode != 401) {
      handler.next(err);
      return;
    }

    debugPrint('🛑 AuthInterceptor - Got 401 Unauthorized, attempting token refresh...');
    if (err.requestOptions.path.contains('/auth/refresh')) {
      debugPrint('🛑 AuthInterceptor - Already refreshing, clearing session');
      await _local.clearSession();
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      debugPrint('🛑 AuthInterceptor - Token refresh returned null, passing error');
      handler.next(err);
      return;
    }

    final requestOptions = err.requestOptions;

    requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
    debugPrint('🛑 AuthInterceptor - Retrying request with new token');

    try {
      final response = await _dio.fetch(requestOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken() async {
    debugPrint('🔐 AuthInterceptor._refreshAccessToken() - attempting token refresh');
    final refreshToken = await _local.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('🔐 AuthInterceptor - No refresh token available, clearing session');
      await _local.clearSession();
      return null;
    }

    if (_isRefreshing) {
      debugPrint('🔐 AuthInterceptor - Refresh already in progress, waiting...');
      return _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      debugPrint('🔐 AuthInterceptor - Calling /auth/refresh to get new access token');
      final auth = await _remote.refresh(refreshToken);
      await _local.saveSession(auth);
      debugPrint('🔐 AuthInterceptor - Token refresh successful, new access token saved');
      _refreshCompleter?.complete(auth.accessToken);
      return auth.accessToken;
    } catch (e) {
      debugPrint('🔐 AuthInterceptor - Token refresh failed: $e, clearing session');
      await _local.clearSession();
      _refreshCompleter?.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}
