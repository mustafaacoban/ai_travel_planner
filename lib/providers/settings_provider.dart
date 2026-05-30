import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _darkModeKey = 'dark_mode';
  static const _languageKey = 'language';

  bool _darkMode = false;
  String _language = 'tr';

  bool get darkMode => _darkMode;
  String get language => _language;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _language = prefs.getString(_languageKey) ?? 'tr';
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _darkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
    notifyListeners();
  }
}
