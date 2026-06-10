import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService extends ChangeNotifier {
  static const String settingsBoxName = 'settings';
  static const String themeColorKey = 'themeColorIndex';
  static const String vibrationKey = 'vibration';
  static const String snoozeDurationKey = 'snoozeDuration';
  static const String maxSnoozesKey = 'maxSnoozes';
  static const String defaultAlarmSoundKey = 'defaultAlarmSound';

  late Box _box;
  int _themeColorIndex = 0; // 0: Purple, 1: Cyan, 2: Green, 3: Amber, 4: Rose
  bool _isVibrationEnabled = true;
  int _defaultSnoozeDuration = 5;
  int _defaultMaxSnoozes = 3;
  String _defaultAlarmSound = 'assets/sounds/Tropical.mp3';

  final List<Color> themeColors = const [
    Color(0xFF8B5CF6), // Purple
    Color(0xFF22D3EE), // Cyan
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFF43F5E), // Rose
  ];

  int get themeColorIndex => _themeColorIndex;
  Color get primaryColor => themeColors[_themeColorIndex];
  bool get isVibrationEnabled => _isVibrationEnabled;
  int get defaultSnoozeDuration => _defaultSnoozeDuration;
  int get defaultMaxSnoozes => _defaultMaxSnoozes;
  String get defaultAlarmSound => _defaultAlarmSound;

  Future<void> init() async {
    _box = await Hive.openBox(settingsBoxName);
    _themeColorIndex = _box.get(themeColorKey, defaultValue: 0);
    _isVibrationEnabled = _box.get(vibrationKey, defaultValue: true);
    _defaultSnoozeDuration = _box.get(snoozeDurationKey, defaultValue: 5);
    _defaultMaxSnoozes = _box.get(maxSnoozesKey, defaultValue: 3);
    _defaultAlarmSound = _box.get(defaultAlarmSoundKey, defaultValue: 'assets/sounds/Tropical.mp3');
  }

  Future<void> setThemeColor(int index) async {
    _themeColorIndex = index;
    await _box.put(themeColorKey, index);
    notifyListeners();
  }

  Future<void> setVibration(bool enabled) async {
    _isVibrationEnabled = enabled;
    await _box.put(vibrationKey, _isVibrationEnabled);
    notifyListeners();
  }

  Future<void> setSnoozeDuration(int duration) async {
    _defaultSnoozeDuration = duration;
    await _box.put(snoozeDurationKey, _defaultSnoozeDuration);
    notifyListeners();
  }

  Future<void> setMaxSnoozes(int max) async {
    _defaultMaxSnoozes = max;
    await _box.put(maxSnoozesKey, _defaultMaxSnoozes);
    notifyListeners();
  }

  Future<void> setDefaultAlarmSound(String path) async {
    _defaultAlarmSound = path;
    await _box.put(defaultAlarmSoundKey, _defaultAlarmSound);
    notifyListeners();
  }
}
