enum Environment { development, production }

class AppConfig {
  static Environment _environment = Environment.production;

  // Base URLs
  static const String _devUrl =
      'https://dashboard.reachinternational.co.in/development/api';
  static const String _liveUrl =
      'https://dashboard.reachinternational.co.in/api';

  // Set environment
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  // Get current base URL
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return _devUrl;
      case Environment.production:
        return _liveUrl;
    }
  }

  // Check current environment
  static bool get isDevelopment =>
      _environment == Environment.development;
  static bool get isProduction =>
      _environment == Environment.production;

  // App name per environment
  static String get appName {
    return isDevelopment
        ? 'Reach CRM (DEV)'
        : 'Reach International CRM';
  }
}