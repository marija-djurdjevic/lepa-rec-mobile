import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLocaleStorage {
  static const _languageCodeKey = 'app_language_code';

  final FlutterSecureStorage _storage;

  AppLocaleStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readLanguageCode() async {
    return _storage.read(key: _languageCodeKey);
  }

  Future<void> saveLanguageCode(String languageCode) async {
    await _storage.write(key: _languageCodeKey, value: languageCode);
  }
}
