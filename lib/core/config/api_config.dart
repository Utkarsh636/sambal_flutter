class ApiConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  static const String host =
      isProduction ? 'api.sambal.app' : '127.0.0.1:3000';
  static const String scheme = isProduction ? 'https' : 'http';
  static const String baseUrl = '$scheme://$host';
}
