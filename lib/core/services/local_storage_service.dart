import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String notesBoxName = 'notes_box';
  static const String settingsBoxName = 'settings_box';

  static late Box notesBox;
  static late SharedPreferences prefs;

  static Future<void> init() async {
    // Initialize Hive for Flutter (Works across Web, Android, iOS, Desktop)
    await Hive.initFlutter();
    notesBox = await Hive.openBox(notesBoxName);
    prefs = await SharedPreferences.getInstance();
  }

  // Theme Settings persistence
  static bool isDarkMode() {
    return prefs.getBool('is_dark_mode') ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    await prefs.setBool('is_dark_mode', isDark);
  }

  // View Mode persistence (Grid vs List)
  static bool isGridView() {
    return prefs.getBool('is_grid_view') ?? true;
  }

  static Future<void> setGridView(bool isGrid) async {
    await prefs.setBool('is_grid_view', isGrid);
  }
}
