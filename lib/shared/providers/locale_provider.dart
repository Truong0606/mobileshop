import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier that manages the app's [Locale] state.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('vi')) {
    _loadLocale();
  }

  static const _key = 'app_language_code';

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_key);
      if (languageCode != null && (languageCode == 'vi' || languageCode == 'en')) {
        state = Locale(languageCode);
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale.languageCode);
    } catch (_) {}
  }

  void setVietnamese() => setLocale(const Locale('vi'));
  void setEnglish() => setLocale(const Locale('en'));
}

/// Global provider for the active [Locale].
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
