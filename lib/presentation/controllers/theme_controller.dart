import 'package:flutter/material.dart';
import '../../core/services/local_storage_service.dart';

class ThemeController extends ChangeNotifier {
  late ThemeMode _themeMode;

  ThemeController() {
    final isDark = LocalStorageService.isDarkMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      LocalStorageService.setDarkMode(false);
    } else {
      _themeMode = ThemeMode.dark;
      LocalStorageService.setDarkMode(true);
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    LocalStorageService.setDarkMode(mode == ThemeMode.dark);
    notifyListeners();
  }
}
