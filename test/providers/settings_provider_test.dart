import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_travel_planner/providers/settings_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SettingsProvider başlangıç değerleri', () {
    test('darkMode false', () async {
      final p = SettingsProvider();
      await Future.delayed(Duration.zero);
      expect(p.darkMode, isFalse);
    });

    test('language tr', () async {
      final p = SettingsProvider();
      await Future.delayed(Duration.zero);
      expect(p.language, 'tr');
    });

    test('themeMode light', () async {
      final p = SettingsProvider();
      await Future.delayed(Duration.zero);
      expect(p.themeMode, ThemeMode.light);
    });
  });

  group('SettingsProvider.toggleDarkMode', () {
    test('toggle ile dark mode açılır', () async {
      final p = SettingsProvider();
      await p.toggleDarkMode();
      expect(p.darkMode, isTrue);
      expect(p.themeMode, ThemeMode.dark);
    });

    test('iki kez toggle false\'a döner', () async {
      final p = SettingsProvider();
      await p.toggleDarkMode();
      await p.toggleDarkMode();
      expect(p.darkMode, isFalse);
    });

    test('dark mode SharedPreferences\'a kaydedilir', () async {
      final p = SettingsProvider();
      await p.toggleDarkMode();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('dark_mode'), isTrue);
    });
  });

  group('SettingsProvider.setLanguage', () {
    test('dil en olarak değiştirilir', () async {
      final p = SettingsProvider();
      await p.setLanguage('en');
      expect(p.language, 'en');
    });

    test('dil SharedPreferences\'a kaydedilir', () async {
      final p = SettingsProvider();
      await p.setLanguage('en');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language'), 'en');
    });

    test('aynı dil set edilince notifyListeners çağrılmaz', () async {
      final p = SettingsProvider();
      int notifyCount = 0;
      p.addListener(() => notifyCount++);
      await p.setLanguage('tr');
      expect(notifyCount, 0);
    });
  });

  group('SettingsProvider kalıcılık', () {
    test('önceden kaydedilmiş değerler yeni instance\'ta okunur', () async {
      SharedPreferences.setMockInitialValues({'dark_mode': true, 'language': 'en'});
      final p = SettingsProvider();
      await Future.delayed(Duration.zero);
      expect(p.darkMode, isTrue);
      expect(p.language, 'en');
    });
  });
}
