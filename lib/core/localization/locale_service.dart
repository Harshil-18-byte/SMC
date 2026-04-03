import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app locale/language
class LocaleService extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English
  static const String _localeKey = 'app_locale';

  Locale get locale => _locale;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('mr'), // Marathi
  ];

  /// Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'mr': 'मराठी',
  };

  LocaleService() {
    _loadLocale();
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      if (languageCode != null) {
        _locale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Get language name for display
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
}


