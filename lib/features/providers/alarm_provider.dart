import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/alarm_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class AlarmProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  late Box<AlarmModel> _alarmBox;

  AlarmProvider(this._storageService, this._notificationService) {
    _alarmBox = _storageService.getAlarmBox();
  }

  List<AlarmModel> get alarms => _alarmBox.values.toList();

  Future<void> addAlarm({
    required int hour,
    required int minute,
    List<String> repeatDays = const [],
    String? label,
    String soundPath = 'default',
    int snoozeDuration = 5,
    int maxSnoozes = 3,
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
      );
      await _alarmBox.put(id, alarm);
      await _notificationService.scheduleAlarm(alarm);
      notifyListeners();
      debugPrint('Alarm added and scheduled: ${alarm.id}');
    } catch (e, stack) {
      debugPrint('Error adding alarm: $e');
      debugPrint(stack.toString());
    }
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    alarm.updatedAt = DateTime.now();
    await alarm.save();
    if (alarm.isEnabled) {
      await _notificationService.scheduleAlarm(alarm);
    } else {
      await _notificationService.cancelAlarm(alarm.id);
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
        await _notificationService.scheduleAlarm(alarm);
      } else {
        await _notificationService.cancelAlarm(alarm.id);
      }
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String id) async {
    await _notificationService.cancelAlarm(id);
    await _alarmBox.delete(id);
    notifyListeners();
  }
}