import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex = 0;

    try {
      final value = prefs.get(_themeKey);
      if (value is int) {
        themeIndex = value;
      } else if (value is String) {
        // Handle legacy string storage if any, or just reset
        if (value == 'ThemeMode.light' || value == 'Light')
          themeIndex = 1;
        else if (value == 'ThemeMode.dark' || value == 'Dark')
          themeIndex = 2;
        else
          themeIndex = 0;

        // Update to int for future
        await prefs.setInt(_themeKey, themeIndex);
      }
    } catch (e) {
      themeIndex = 0;
    }

    if (themeIndex < 0 || themeIndex >= ThemeMode.values.length) {
      themeIndex = 0;
    }

    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
    notifyListeners();
  }
}
