import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studify/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial theme is System', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('loadTheme loads theme from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 2}); // 2 is Dark

      final provider = ThemeProvider();
      await provider.loadTheme();

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('loadTheme handles legacy string values', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'Light'});

      final provider = ThemeProvider();
      await provider.loadTheme();

      expect(provider.themeMode, ThemeMode.light);
    });

    test('themeModeString returns correct string', () {
      final provider = ThemeProvider();
      expect(provider.themeModeString, 'System');
    });
  });
}
