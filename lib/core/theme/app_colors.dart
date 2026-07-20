import 'package:flutter/material.dart';

/// Premium color palette for the Smart Shopping Chatbot.
///
/// Provides a cohesive set of colors for both light and dark themes,
/// including gradients, chat-specific colors, and semantic status colors.
sealed class AppColors {
  // ──────────────────────────────────────────────
  // Brand Colors
  // ──────────────────────────────────────────────
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);

  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF67E8F9);
  static const Color secondaryDark = Color(0xFF0891B2);

  // ──────────────────────────────────────────────
  // Light Mode – Surfaces & Backgrounds
  // ──────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F1F5);
  static const Color lightSurfaceContainer = Color(0xFFE8EAF0);
  static const Color lightOnBackground = Color(0xFF1A1A2E);
  static const Color lightOnSurface = Color(0xFF2D2D3F);
  static const Color lightOnSurfaceVariant = Color(0xFF6B6B80);

  // ──────────────────────────────────────────────
  // Dark Mode – Surfaces & Backgrounds
  // ──────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF161625);
  static const Color darkSurfaceVariant = Color(0xFF1E1E32);
  static const Color darkSurfaceContainer = Color(0xFF25253D);
  static const Color darkOnBackground = Color(0xFFE8E8F0);
  static const Color darkOnSurface = Color(0xFFD4D4E0);
  static const Color darkOnSurfaceVariant = Color(0xFF9898B0);

  // ──────────────────────────────────────────────
  // Chat Bubble Colors
  // ──────────────────────────────────────────────
  static const Color userBubbleLight = Color(0xFF10B981);
  static const Color userBubbleDark = Color(0xFF059669);
  static const Color userBubbleText = Color(0xFFFFFFFF);

  static const Color botBubbleLight = Color(0xFFF0F1F5);
  static const Color botBubbleDark = Color(0xFF1E1E32);
  static const Color botBubbleTextLight = Color(0xFF2D2D3F);
  static const Color botBubbleTextDark = Color(0xFFD4D4E0);

  // ──────────────────────────────────────────────
  // Gradients
  // ──────────────────────────────────────────────
  static const Color gradientStart = Color(0xFF10B981);
  static const Color gradientMiddle = Color(0xFF059669);
  static const Color gradientEnd = Color(0xFF06B6D4);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMiddle],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient surfaceGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, darkSurface],
  );

  // ──────────────────────────────────────────────
  // Semantic / Status Colors
  // ──────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ──────────────────────────────────────────────
  // Miscellaneous
  // ──────────────────────────────────────────────
  static const Color dividerLight = Color(0xFFE2E4EA);
  static const Color dividerDark = Color(0xFF2A2A42);

  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2A2A42);
  static const Color shimmerHighlightDark = Color(0xFF3A3A55);

  static const Color shadow = Color(0x1A000000);
  static const Color scrim = Color(0x80000000);

  /// Prevents instantiation.
  const AppColors._();
}
