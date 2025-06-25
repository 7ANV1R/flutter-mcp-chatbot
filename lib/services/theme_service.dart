import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';

  late SharedPreferences _prefs;
  AppThemeMode _themeMode = AppThemeMode.system;
  PrimaryColorTheme _primaryColorTheme = PrimaryColorTheme.blue;

  AppThemeMode get themeMode => _themeMode;
  PrimaryColorTheme get primaryColorTheme => _primaryColorTheme;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    // Load theme mode
    final themeModeString = _prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == themeModeString,
        orElse: () => AppThemeMode.system,
      );
    }

    // Load primary color theme
    final primaryColorString = _prefs.getString(_primaryColorKey);
    if (primaryColorString != null) {
      _primaryColorTheme = PrimaryColorTheme.fromString(primaryColorString);
    }

    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setPrimaryColorTheme(PrimaryColorTheme colorTheme) async {
    _primaryColorTheme = colorTheme;
    await _prefs.setString(_primaryColorKey, colorTheme.name);
    notifyListeners();
  }

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
