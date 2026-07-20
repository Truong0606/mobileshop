import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application typography scale built on top of Google Fonts Inter.
///
/// All styles are provided as static getters so that [GoogleFonts] can
/// resolve the font family at runtime (it is not a compile-time constant).
sealed class AppTypography {
  // ──────────────────────────────────────────────
  // Headings
  // ──────────────────────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static TextStyle get headingMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get headingSmall => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
  );

  // ──────────────────────────────────────────────
  // Body
  // ──────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.45,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ──────────────────────────────────────────────
  // Labels
  // ──────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.35,
  );

  // ──────────────────────────────────────────────
  // Chat-specific
  // ──────────────────────────────────────────────
  static TextStyle get chatMessage => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static TextStyle get chatTimestamp => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  /// Returns a complete [TextTheme] built from the styles above.
  ///
  /// Pass this to [ThemeData.textTheme] for consistent Material styling.
  static TextTheme get textTheme => TextTheme(
    displayLarge: headingLarge,
    displayMedium: headingMedium,
    displaySmall: headingSmall,
    headlineLarge: headingLarge,
    headlineMedium: headingMedium,
    headlineSmall: headingSmall,
    titleLarge: headingSmall,
    titleMedium: labelLarge,
    titleSmall: labelMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: chatTimestamp,
  );

  /// Prevents instantiation.
  const AppTypography._();
}
