import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/alarm_model.dart';
import '../models/mood_entry_model.dart';

class StorageService {
  static const String alarmBoxName = 'alarms';
  static const String moodBoxName = 'mood_entries';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AlarmModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MoodEntryModelAdapter());
    }

    // Open Boxes
    try {
      await Hive.openBox<AlarmModel>(alarmBoxName);
    } catch (e) {
      debugPrint('Error opening alarm box: $e. Deleting and recreating.');
      await Hive.deleteBoxFromDisk(alarmBoxName);
      await Hive.openBox<AlarmModel>(alarmBoxName);
    }

    try {
      await Hive.openBox<MoodEntryModel>(moodBoxName);
    } catch (e) {
      debugPrint('Error opening mood box: $e. Deleting and recreating.');
      await Hive.deleteBoxFromDisk(moodBoxName);
      await Hive.openBox<MoodEntryModel>(moodBoxName);
    }
  }

  Box<AlarmModel> getAlarmBox() => Hive.box<AlarmModel>(alarmBoxName);
  Box<MoodEntryModel> getMoodBox() => Hive.box<MoodEntryModel>(moodBoxName);
}
