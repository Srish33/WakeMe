import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/alarm_model.dart';
import '../models/mood_entry_model.dart';
import '../models/routine_task_model.dart';
import '../models/analytics_model.dart';

// Manages persistent local data storage using Hive.
// Handles adapter registration and safe box initialization.
class StorageService {
  static const String alarmBoxName = 'alarms';
  static const String moodBoxName = 'mood_entries';
  static const String alarmAnalyticsBoxName = 'alarm_analytics';
  static const String routineAnalyticsBoxName = 'routine_analytics';
  static const String challengeLevelsBoxName = 'challenge_levels';

  // Bootstraps the local database engine and defines object relationships.
  Future<void> init() async {
    await Hive.initFlutter();

    // Register Data Adapters for Hive binary serialization
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AlarmModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MoodEntryModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(RoutineTaskAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(AlarmAnalyticsAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(RoutineAnalyticsAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ChallengeAnalyticsAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(ChallengeTypeAdapter());

    // Open and verify individual data stores
    await _openBoxSafe<AlarmModel>(alarmBoxName);
    await _openBoxSafe<MoodEntryModel>(moodBoxName);
    await _openBoxSafe<AlarmAnalytics>(alarmAnalyticsBoxName);
    await _openBoxSafe<RoutineAnalytics>(routineAnalyticsBoxName);
    await Hive.openBox<int>(challengeLevelsBoxName); // Store difficulty level (1-3)
  }

  // Safely attempts to open a box, wiping it only if corruption is detected.
  Future<void> _openBoxSafe<T>(String name) async {
    try {
      await Hive.openBox<T>(name);
    } catch (e) {
      debugPrint('Error opening Hive box "$name": $e. Attempting recovery.');
      try {
        // Force clear any potential lock files or corrupted data
        await Hive.deleteBoxFromDisk(name);
      } catch (deleteError) {
        debugPrint('Recovery: Could not delete box from disk: $deleteError');
      }
      // Final attempt to open (will create fresh if deleted, or throw to main if still blocked)
      await Hive.openBox<T>(name);
    }
  }

  // Accessors for pre-opened data boxes
  Box<AlarmModel> getAlarmBox() => Hive.box<AlarmModel>(alarmBoxName);
  Box<MoodEntryModel> getMoodBox() => Hive.box<MoodEntryModel>(moodBoxName);
  Box<AlarmAnalytics> getAlarmAnalyticsBox() => Hive.box<AlarmAnalytics>(alarmAnalyticsBoxName);
  Box<RoutineAnalytics> getRoutineAnalyticsBox() => Hive.box<RoutineAnalytics>(routineAnalyticsBoxName);
  Box<int> getChallengeLevelsBox() => Hive.box<int>(challengeLevelsBoxName);
}
