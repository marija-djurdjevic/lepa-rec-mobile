import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';

class AuthLocalDataSource {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'expires_at';
  static const _userIdKey = 'user_id';
  static const _roleKey = 'role';

  final FlutterSecureStorage _storage;

  AuthLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession(AuthResponse auth) async {
    debugPrint('🔐 AuthLocalDataSource.saveSession() - storing tokens...');
    await _storage.write(key: _accessTokenKey, value: auth.accessToken);
    debugPrint('🔐 AuthLocalDataSource - access token saved');
    await _storage.write(key: _refreshTokenKey, value: auth.refreshToken);
    debugPrint('🔐 AuthLocalDataSource - refresh token saved');
    await _storage.write(key: _expiresAtKey, value: auth.expiresAt.toIso8601String());
    await _storage.write(key: _userIdKey, value: auth.userId);
    await _storage.write(key: _roleKey, value: auth.role);
    debugPrint('🔐 AuthLocalDataSource - all session data saved');
  }

  Future<String?> readAccessToken() async {
    debugPrint('🔐 AuthLocalDataSource.readAccessToken() - reading from storage');
    final token = await _storage.read(key: _accessTokenKey);
    debugPrint('🔐 AuthLocalDataSource - access token exists: ${token != null && token.isNotEmpty}');
    return token;
  }

  Future<String?> readRefreshToken() async {
    debugPrint('🔐 AuthLocalDataSource.readRefreshToken() - reading from storage');
    final token = await _storage.read(key: _refreshTokenKey);
    debugPrint('🔐 AuthLocalDataSource - refresh token exists: ${token != null && token.isNotEmpty}');
    return token;
  }

  Future<void> clearSession() async {
    debugPrint('🔐 AuthLocalDataSource.clearSession() - clearing all tokens');
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiresAtKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _roleKey);
    debugPrint('🔐 AuthLocalDataSource - all session data cleared');
  }
}
