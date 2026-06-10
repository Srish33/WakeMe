import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/alarm_model.dart';
import '../models/routine_task_model.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';
import 'package:uuid/uuid.dart';

class AlarmProvider extends ChangeNotifier {
  final StorageService _storageService;
  late Box<AlarmModel> _alarmBox;
  late Box<int> _challengeLevelsBox;
  
  final Map<int, int> _snoozeCounts = {};
  
  // Session failure tracking for challenges
  int _consecutiveFailures = 0;
  int _totalFailures = 0;
  int _failedAttemptsOnCurrentLevel = 0;
  bool _assistedMode = false;

  AlarmProvider(this._storageService) {
    _alarmBox = _storageService.getAlarmBox();
    _challengeLevelsBox = _storageService.getChallengeLevelsBox();
  }

  List<AlarmModel> get alarms => _alarmBox.values.toList();

  // Challenge logic getters
  int get consecutiveFailures => _consecutiveFailures;
  int get totalFailures => _totalFailures;
  bool get assistedMode => _assistedMode;

  int getChallengeLevel(ChallengeType type) {
    return _challengeLevelsBox.get(type.name, defaultValue: 1) ?? 1;
  }

  // Refined: Logic to manage difficulty progression and adaptive reduction
  void updateChallengeLevel(ChallengeType type, bool success) {
    int current = getChallengeLevel(type);
    if (success) {
      if (current < 3) {
        _challengeLevelsBox.put(type.name, current + 1);
      }
      // Reset session failures on complete success
      resetChallengeSession();
    } else {
      _totalFailures++;
      _consecutiveFailures++;
      _failedAttemptsOnCurrentLevel++;
      
      // Reduce difficulty ONLY after 2 failed attempts on this level
      if (_failedAttemptsOnCurrentLevel >= 2) {
        if (current > 1) {
          _challengeLevelsBox.put(type.name, current - 1);
        }
        _failedAttemptsOnCurrentLevel = 0; // Reset counter for the new (lower) level
      }

      // Check for Assisted Completion Mode: 2 consecutive AND 3 total
      if (_consecutiveFailures >= 2 && _totalFailures >= 3) {
        _assistedMode = true;
      }
    }
    notifyListeners();
  }

  void resetChallengeSession() {
    _consecutiveFailures = 0;
    _totalFailures = 0;
    _failedAttemptsOnCurrentLevel = 0;
    _assistedMode = false;
    notifyListeners();
  }

  // Existing methods
  AlarmModel? getAlarmByHashCode(int hashCode) {
    try {
      return _alarmBox.values.firstWhere((a) => 
        a.id.hashCode == hashCode || 
        a.id.hashCode + 1 == hashCode || 
        a.id.hashCode + 2 == hashCode
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> addAlarm({
    required int hour,
    required int minute,
    List<String> repeatDays = const [],
    String? label,
    required String soundPath,
    required int snoozeDuration,
    required int maxSnoozes,
    List<RoutineTask> routineTasks = const [],
    String routineReminderSoundPath = 'default',
    ChallengeType challengeType = ChallengeType.memorySequence,
    int stepGoal = 10,
    String? barcodeData,
    String? referencePhotoPath,
  }) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();
      final alarm = AlarmModel(
        id: id,
        hour: hour,
        minute: minute,
        repeatDays: repeatDays,
        label: label,
        soundPath: soundPath,
        snoozeDuration: snoozeDuration,
        maxSnoozes: maxSnoozes,
        createdAt: now,
        updatedAt: now,
        routineTasks: routineTasks,
        routineReminderSoundPath: routineReminderSoundPath,
        challengeType: challengeType,
        stepGoal: stepGoal,
        barcodeData: barcodeData,
        referencePhotoPath: referencePhotoPath,
      );
      await _alarmBox.put(id, alarm);
      if (alarm.isEnabled) {
        await AlarmService.setAlarm(alarm);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding alarm: $e');
    }
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    alarm.updatedAt = DateTime.now();
    await alarm.save();
    if (alarm.isEnabled) {
      await AlarmService.setAlarm(alarm);
    } else {
      await AlarmService.stopAlarm(alarm.id.hashCode);
    }
    notifyListeners();
  }

  Future<void> toggleAlarm(String id) async {
    final alarm = _alarmBox.get(id);
    if (alarm != null) {
      alarm.isEnabled = !alarm.isEnabled;
      alarm.updatedAt = DateTime.now();
      await alarm.save();

      if (alarm.isEnabled) {
        await AlarmService.setAlarm(alarm);
      } else {
        await AlarmService.stopAlarm(alarm.id.hashCode);
      }
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String id) async {
    await AlarmService.stopAlarm(id.hashCode);
    await _alarmBox.delete(id);
    notifyListeners();
  }

  void incrementSnoozeCount(int alarmId) {
    _snoozeCounts[alarmId] = (_snoozeCounts[alarmId] ?? 0) + 1;
    notifyListeners();
  }

  int getSnoozeCount(int alarmId) => _snoozeCounts[alarmId] ?? 0;

  void resetSnoozeCount(int alarmId) {
    _snoozeCounts.remove(alarmId);
    notifyListeners();
  }
}
