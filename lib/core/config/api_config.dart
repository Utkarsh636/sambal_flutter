class ApiConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  static const String _prodHost =
      String.fromEnvironment('API_HOST', defaultValue: 'api.sambal.app');
  static const String host = isProduction ? _prodHost : '127.0.0.1:3000';
  static const String scheme = isProduction ? 'https' : 'http';
  static const String baseUrl = '$scheme://$host';
}
