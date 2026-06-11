class ApiEnvironment {
  static const String _prodBaseUrl = 'https://api.sagledaj.com/api';
  static const String _defaultDevBaseUrl = 'http://localhost:8080/api';

  static const String _appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static const bool isProduction =
      _appEnv == 'prod' || _appEnv == 'production';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: isProduction
        ? _prodBaseUrl
        : String.fromEnvironment(
            'DEV_API_BASE_URL',
            defaultValue: _defaultDevBaseUrl,
          ),
  );
}
