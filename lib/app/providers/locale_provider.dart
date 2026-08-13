import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's locale and persists the user's language preference.
class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale';

  Locale _locale = const Locale('en', 'US');
  Locale get locale => _locale;

  bool get isEnglish => _locale.languageCode == 'en';

  /// Call once at startup to load the saved locale from SharedPreferences.
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      _locale = _parseLocale(saved);
      notifyListeners();
    }
  }

  /// Switch to the given locale and persist it.
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, '${newLocale.languageCode}_${newLocale.countryCode ?? ''}');
  }

  /// Convenience: switch to English.
  Future<void> switchToEnglish() => setLocale(const Locale('en', 'US'));

  /// Convenience: switch to Indonesian.
  Future<void> switchToIndonesian() => setLocale(const Locale('id', 'ID'));

  Locale _parseLocale(String value) {
    final parts = value.split('_');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }
}
