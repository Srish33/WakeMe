import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService extends ChangeNotifier {
  static const String themeBoxName = 'settings';
  static const String themeModeKey = 'themeMode';

  late Box _box;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    _box = await Hive.openBox(themeBoxName);
    _isDarkMode = _box.get(themeModeKey, defaultValue: true);
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _box.put(themeModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setThemeMode(bool isDark) async {
    _isDarkMode = isDark;
    await _box.put(themeModeKey, _isDarkMode);
    notifyListeners();
  }
}
