enum Environment { staging, production }

class EnvConfig {
  static Environment _environment = Environment.staging;

  static void init(Environment env) {
    _environment = env;
  }

  static Environment get current => _environment;

  static String get baseUrl {
    switch (_environment) {
      case Environment.production:
        return 'https://delivery-app-prod-backend-production.up.railway.app';
      case Environment.staging:
        // URL Corregida: staging-backend en lugar de backend-staging
        return 'https://delivery-app-staging-backend.up.railway.app';
    }
  }

  // Helper for direct access if needed
  String get currentBaseUrl => baseUrl;
}
