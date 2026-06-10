import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/analytics_model.dart';
import '../models/mood_entry_model.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// Calculates and serves technical metrics and trends for the Reports screen
class AnalyticsProvider extends ChangeNotifier {
  final StorageService _storageService;
  late Box<AlarmAnalytics> _alarmAnalyticsBox;
  late Box<RoutineAnalytics> _routineAnalyticsBox;
  late Box<MoodEntryModel> _moodBox;

  AnalyticsProvider(this._storageService) {
    _alarmAnalyticsBox = _storageService.getAlarmAnalyticsBox();
    _routineAnalyticsBox = _storageService.getRoutineAnalyticsBox();
    _moodBox = _storageService.getMoodBox();

    // Establish real-time data binding to refresh Reports when database state changes
    _alarmAnalyticsBox.watch().listen((_) => notifyListeners());
    _routineAnalyticsBox.watch().listen((_) => notifyListeners());
    _moodBox.watch().listen((_) => notifyListeners());
  }

  // Returns raw data logs sorted by most recent first
  List<AlarmAnalytics> get alarmAnalytics => _alarmAnalyticsBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  List<RoutineAnalytics> get routineAnalytics => _routineAnalyticsBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  // Records technical performance after an alarm is successfully dismissed
  Future<void> recordAlarmSession({
    required DateTime alarmTime,
    required DateTime actualWakeUpTime,
    required int snoozeCount,
  }) async {
    final delay = actualWakeUpTime.difference(alarmTime).inMinutes;
    final analytics = AlarmAnalytics(
      id: const Uuid().v4(),
      alarmTime: alarmTime,
      actualWakeUpTime: actualWakeUpTime,
      wakeUpDelayMinutes: delay < 0 ? 0 : delay,
      snoozeCount: snoozeCount,
      date: DateTime.now(),
    );
    await _alarmAnalyticsBox.put(analytics.id, analytics);
    notifyListeners();
  }

  // Records the efficiency of the morning routine flow
  Future<void> recordRoutineSession({
    required DateTime startTime,
    required DateTime endTime,
    required int additionalTimeRequested,
  }) async {
    final duration = endTime.difference(startTime).inMinutes;
    final analytics = RoutineAnalytics(
      id: const Uuid().v4(),
      startTime: startTime,
      endTime: endTime,
      durationMinutes: duration,
      additionalTimeMinutes: additionalTimeRequested,
      date: DateTime.now(),
    );
    await _routineAnalyticsBox.put(analytics.id, analytics);
    notifyListeners();
  }

  // Computed metrics for Alarm Performance
  double get averageSnoozes => alarmAnalytics.isEmpty 
      ? 0 
      : alarmAnalytics.map((e) => e.snoozeCount).reduce((a, b) => a + b) / alarmAnalytics.length;

  int get totalSnoozes => alarmAnalytics.isEmpty
      ? 0
      : alarmAnalytics.map((e) => e.snoozeCount).fold(0, (a, b) => a + b);

  int get totalAlarmsTriggered => alarmAnalytics.length;

  // New: Average Wake-Up Time Calculation
  String get averageWakeUpTimeStr {
    if (alarmAnalytics.isEmpty) return "N/A";
    
    int totalMinutesFromMidnight = 0;
    for (var session in alarmAnalytics) {
      totalMinutesFromMidnight += (session.actualWakeUpTime.hour * 60) + session.actualWakeUpTime.minute;
    }
    
    int avgMinutes = totalMinutesFromMidnight ~/ alarmAnalytics.length;
    int hour = (avgMinutes ~/ 60) % 24;
    int minute = avgMinutes % 60;
    
    final tempDate = DateTime(2024, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(tempDate);
  }

  // New: Wake-Up Window Calculation (30-min window)
  String get wakeUpWindowStr {
    if (alarmAnalytics.isEmpty) return "N/A";
    
    int totalMinutesFromMidnight = 0;
    for (var session in alarmAnalytics) {
      totalMinutesFromMidnight += (session.actualWakeUpTime.hour * 60) + session.actualWakeUpTime.minute;
    }
    
    int avgMinutes = totalMinutesFromMidnight ~/ alarmAnalytics.length;
    
    String format(int mins) {
      int totalMins = mins;
      if (totalMins < 0) totalMins += 1440;
      int h = (totalMins ~/ 60) % 24;
      int m = totalMins % 60;
      return DateFormat('h:mm a').format(DateTime(2024, 1, 1, h, m));
    }
    
    return "${format(avgMinutes - 15)} and ${format(avgMinutes + 15)}";
  }

  // Streak logic: Count consecutive sessions with 0 snoozes (Clean Wake-ups)
  int get noSnoozeStreak {
    if (alarmAnalytics.isEmpty) return 0;
    var streak = 0;
    for (var session in alarmAnalytics) {
      if (session.snoozeCount == 0) streak++;
      else break;
    }
    return streak;
  }

  // Record of the highest consecutive clean wake-ups ever achieved
  int get maxNoSnoozeStreak {
    if (alarmAnalytics.isEmpty) return 0;
    var maxStreak = 0;
    var currentStreak = 0;
    for (var session in alarmAnalytics.reversed) {
      if (session.snoozeCount == 0) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }
    return maxStreak;
  }

  // Mood Score Mapping (1-5 Scale)
  int getMoodScore(String mood) {
    switch (mood) {
      case '😴': return 1;
      case '😐': return 2;
      case '🙂': return 3;
      case '😊': return 4;
      case '🤩': return 5;
      default: return 3;
    }
  }

  // Inverse Mapping for Chart Axes
  String getMoodFromScore(int score) {
    switch (score) {
      case 1: return '😴';
      case 2: return '😐';
      case 3: return '🙂';
      case 4: return '😊';
      case 5: return '🤩';
      default: return '🙂';
    }
  }

  // Returns percentage distribution of moods for the bar chart
  Map<String, double> get moodDistribution {
    if (_moodBox.isEmpty) return {};
    final total = _moodBox.length;
    final counts = <String, int>{};
    for (var entry in _moodBox.values) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    return counts.map((key, value) => MapEntry(key, (value / total) * 100));
  }

  // Calculates the best emoji based on highest score recorded
  String get bestMood {
    if (_moodBox.isEmpty) return 'None';
    final scores = _moodBox.values.map((e) => getMoodScore(e.mood)).toList();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    return getMoodFromScore(maxScore);
  }

  // New: Mood of the Month
  String get moodOfTheMonth {
    if (_moodBox.isEmpty) return "N/A";
    final now = DateTime.now();
    final currentMonthEntries = _moodBox.values.where((e) => e.createdAt.month == now.month && e.createdAt.year == now.year).toList();
    
    if (currentMonthEntries.isEmpty) return "N/A";
    
    final counts = <String, int>{};
    for (var entry in currentMonthEntries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    
    var topMoodEntry = counts.entries.first;
    for (var entry in counts.entries) {
      if (entry.value > topMoodEntry.value) topMoodEntry = entry;
    }
    return topMoodEntry.key;
  }

  // Journaling Statistics
  int get totalJournalEntries => _moodBox.length;
  int get entriesThisMonth {
    final now = DateTime.now();
    return _moodBox.values.where((e) => e.createdAt.month == now.month && e.createdAt.year == now.year).length;
  }

  // Current consecutive days journaling
  int get currentStreak {
    if (_moodBox.isEmpty) return 0;
    final dates = _moodBox.values.map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day)).toSet().toList()..sort((a, b) => b.compareTo(a));
    
    var today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (dates.first.isBefore(today.subtract(const Duration(days: 1)))) return 0;
    
    var streak = 1;
    var currentDate = dates.first;
    for (var i = 1; i < dates.length; i++) {
      if (dates[i] == currentDate.subtract(const Duration(days: 1))) {
        streak++;
        currentDate = dates[i];
      } else break;
    }
    return streak;
  }

  // All-time highest journal streak
  int get longestStreak {
     if (_moodBox.isEmpty) return 0;
    final dates = _moodBox.values.map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day)).toSet().toList()..sort((a, b) => a.compareTo(b));
    
    var maxStreak = 1;
    var currentStreak = 1;
    for (var i = 1; i < dates.length; i++) {
      if (dates[i] == dates[i-1].add(const Duration(days: 1))) {
        currentStreak++;
      } else {
        if (currentStreak > maxStreak) maxStreak = currentStreak;
        currentStreak = 1;
      }
    }
    return currentStreak > maxStreak ? currentStreak : maxStreak;
  }

  // Filters data for the 7-day trend chart
  List<MoodEntryModel> get last7DaysMoods {
    final entries = _moodBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries.take(7).toList().reversed.toList();
  }

  // New: Filters data for the last 7 wake-ups (minutes from midnight for Y axis)
  List<AlarmAnalytics> get last7DaysWakeUps {
    final entries = alarmAnalytics.take(7).toList().reversed.toList();
    return entries;
  }
}
