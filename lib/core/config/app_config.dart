import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supported application environments.
enum Environment { dev, staging, prod }

/// Immutable, environment-aware configuration for the app.
///
/// Reads from `.env` file via `flutter_dotenv`. The singleton [instance]
/// is set once at app startup via [AppConfig.init] and read everywhere else.
class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.chatbotApiBaseUrl,
    required this.wsUrl,
    required this.chatbotApiKey,
    this.enableLogging = false,
    this.enableAnalytics = false,
    this.connectionTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
  });

  // ──────────────────────────────────────────────
  // Singleton
  // ──────────────────────────────────────────────
  static AppConfig? _instance;

  /// The current app configuration.
  ///
  /// Throws [StateError] if accessed before [init] is called.
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppConfig has not been initialised. '
        'Call AppConfig.init() in main() before runApp().',
      );
    }
    return _instance!;
  }

  /// Initialise the global configuration from `.env` values.
  ///
  /// Reads `API_BASE_URL`, `CHATBOT_API_BASE_URL`, `WS_URL`, and `APP_ENV` from the loaded dotenv.
  static void init() {
    final envStr = dotenv.env['APP_ENV'] ?? 'dev';
    final environment = Environment.values.firstWhere(
      (e) => e.name == envStr,
      orElse: () => Environment.dev,
    );

    final apiBaseUrl =
        dotenv.env['API_BASE_URL'] ?? _fallbackApiUrl(environment);
    final chatbotApiBaseUrl =
        dotenv.env['CHATBOT_API_BASE_URL'] ?? 'https://mahihi.com/api/v1';
    final wsUrl = dotenv.env['WS_URL'] ?? _fallbackWsUrl(environment);
    final chatbotApiKey = dotenv.env['CHATBOT_API_KEY'] ?? '';

    _instance = AppConfig._(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      chatbotApiBaseUrl: chatbotApiBaseUrl,
      wsUrl: wsUrl,
      chatbotApiKey: chatbotApiKey,
      enableLogging: environment != Environment.prod,
      enableAnalytics: environment == Environment.prod,
      connectionTimeout: Duration(
        seconds: environment == Environment.prod ? 15 : 30,
      ),
      receiveTimeout: Duration(
        seconds: environment == Environment.prod ? 15 : 30,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Properties
  // ──────────────────────────────────────────────
  final Environment environment;
  final String apiBaseUrl;
  final String chatbotApiBaseUrl;
  final String wsUrl;
  final String chatbotApiKey;
  final bool enableLogging;
  final bool enableAnalytics;
  final Duration connectionTimeout;
  final Duration receiveTimeout;

  /// Whether the app is running in production.
  bool get isProduction => environment == Environment.prod;

  /// Whether the app is running in development.
  bool get isDevelopment => environment == Environment.dev;

  // ──────────────────────────────────────────────
  // Fallback URLs (used when .env is missing values)
  // ──────────────────────────────────────────────
  static String _fallbackApiUrl(Environment env) {
    switch (env) {
      case Environment.dev:
      case Environment.staging:
      case Environment.prod:
        return 'https://shoppe-fake-427087851138.asia-southeast1.run.app/api/v1';
    }
  }

  static String _fallbackWsUrl(Environment env) {
    switch (env) {
      case Environment.dev:
      case Environment.staging:
      case Environment.prod:
        return 'wss://shoppe-fake-427087851138.asia-southeast1.run.app/ws';
    }
  }

  @override
  String toString() =>
      'AppConfig(environment: ${environment.name}, api: $apiBaseUrl)';
}
