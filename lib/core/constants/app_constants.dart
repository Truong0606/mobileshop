/// App-wide constant values.
///
/// Centralised so magic numbers never leak into widget code.
sealed class AppConstants {
  // ──────────────────────────────────────────────
  // General
  // ──────────────────────────────────────────────
  static const String appName = 'Smart Shopping';
  static const String appTagline = 'Your AI Shopping Assistant';
  static const String appVersion = '0.1.0';

  // ──────────────────────────────────────────────
  // API
  // ──────────────────────────────────────────────
  static const String apiBaseUrl = 'https://api.smartshopping.example.com';
  static const String wsBaseUrl = 'wss://ws.smartshopping.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration wsReconnectDelay = Duration(seconds: 5);
  static const int maxRetries = 3;

  // ──────────────────────────────────────────────
  // Animation Durations
  // ──────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animPageTransition = Duration(milliseconds: 350);
  static const Duration animChatBubble = Duration(milliseconds: 250);

  // ──────────────────────────────────────────────
  // Spacing & Padding
  // ──────────────────────────────────────────────
  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;
  static const double spacingXxxl = 48.0;

  static const double paddingScreen = 16.0;
  static const double paddingCard = 16.0;
  static const double paddingDialog = 24.0;

  // ──────────────────────────────────────────────
  // Border Radii
  // ──────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ──────────────────────────────────────────────
  // Chat
  // ──────────────────────────────────────────────
  static const int maxChatMessageLength = 2000;
  static const int chatHistoryPageSize = 30;
  static const double chatBubbleMaxWidthFactor = 0.78;

  // ──────────────────────────────────────────────
  // Product Grid
  // ──────────────────────────────────────────────
  static const int productGridCrossAxisCount = 2;
  static const double productCardAspectRatio = 0.72;

  /// Prevents instantiation.
  const AppConstants._();
}
