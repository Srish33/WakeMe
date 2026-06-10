import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/alarm_model.dart';

// Static service for interfacing with the native alarm package and permission handling
class AlarmService {
  // Initialize the native alarm engine
  static Future<void> init() async {
    await Alarm.init();
  }

  // Verifies if the 'Schedule Exact Alarm' permission is granted on Android
  static Future<bool> checkExactAlarmPermission() async {
    if (Platform.isAndroid) {
      return await Permission.scheduleExactAlarm.isGranted;
    }
    return true;
  }

  // Orchestrates permission requests for both alarms and push notifications
  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
      await Permission.notification.request();
    }
  }

  // Configures and schedules a background alarm with specific audio and volume settings
  static Future<void> setAlarm(AlarmModel alarm) async {
    final now = DateTime.now();
    DateTime scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.hour,
      alarm.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: alarm.id.hashCode,
      dateTime: scheduledDateTime,
      assetAudioPath: alarm.soundPath == 'default' 
          ? 'assets/sounds/alarm.mp3' 
          : alarm.soundPath,
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: 'WaKeMe',
        body: alarm.label ?? 'Time to wake up!',
        stopButton: 'Dismiss',
      ),
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint('Alarm set for $scheduledDateTime');
  }

  // Stops a specific alarm from ringing
  static Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
  }

  // Immediately triggers an alarm with high urgency (Dead Man Switch)
  static Future<void> triggerSafetyAlarm(AlarmModel alarm, {bool isRoutineCompletion = false, Duration delay = const Duration(milliseconds: 100), bool loopAudio = true}) async {
    // Use the dedicated routine sound for completion, otherwise the main alarm sound
    final soundToUse = isRoutineCompletion ? alarm.routineReminderSoundPath : alarm.soundPath;
    
    final alarmSettings = AlarmSettings(
      id: isRoutineCompletion ? alarm.id.hashCode + 2 : alarm.id.hashCode + 3,
      dateTime: DateTime.now().add(delay),
      assetAudioPath: soundToUse == 'default' 
          ? 'assets/sounds/alarm.mp3' 
          : soundToUse,
      loopAudio: loopAudio,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(volume: 1.0),
      notificationSettings: NotificationSettings(
        title: isRoutineCompletion ? 'ROUTINE COMPLETE?' : 'STILL AWAKE?',
        body: isRoutineCompletion ? 'Time to check off your morning tasks.' : 'You haven\'t completed your morning check-in!',
        stopButton: 'Dismiss',
      ),
      androidFullScreenIntent: true,
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  // Stops all possible alarms associated with a specific alarm session
  static Future<void> stopSessionAlarms(int hashCode) async {
    await Alarm.stop(hashCode);     // Main alarm
    await Alarm.stop(hashCode + 1); // Snooze/Reminder
    await Alarm.stop(hashCode + 2); // Routine completion
    await Alarm.stop(hashCode + 3); // Safety/Inactivity
  }

  // Forces all active alarms to terminate
  static Future<void> stopAll() async {
    final alarms = await Alarm.getAlarms();
    for (final a in alarms) {
      await Alarm.stop(a.id);
    }
  }
}
