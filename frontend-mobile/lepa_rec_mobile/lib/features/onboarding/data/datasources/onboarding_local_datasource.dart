import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingLocalDataSource {
  static const _sessionIdKey = 'onboarding_session_id';

  final FlutterSecureStorage _storage;

  OnboardingLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSessionId(String sessionId) {
    return _storage.write(key: _sessionIdKey, value: sessionId);
  }

  Future<String?> readSessionId() {
    return _storage.read(key: _sessionIdKey);
  }

  Future<void> clearSessionId() {
    return _storage.delete(key: _sessionIdKey);
  }
}

