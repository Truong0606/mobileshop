import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that manages the app's [ThemeMode] state.
///
/// Supports light, dark, and system modes. The current choice is held
/// in-memory; persistence can be added later via SharedPreferences.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  /// Set the theme to [ThemeMode.light].
  void setLight() => state = ThemeMode.light;

  /// Set the theme to [ThemeMode.dark].
  void setDark() => state = ThemeMode.dark;

  /// Set the theme to [ThemeMode.system] (follow OS setting).
  void setSystem() => state = ThemeMode.system;

  /// Toggle between light and dark (ignores system).
  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Set an arbitrary [ThemeMode].
  void setMode(ThemeMode mode) => state = mode;
}

/// Global provider that exposes the current [ThemeMode].
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);
