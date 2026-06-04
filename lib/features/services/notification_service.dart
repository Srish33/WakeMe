import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/alarm_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone().then((info) => info.identifier);
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Error initializing local timezone: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.hour,
        alarm.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // If repeatDays is set, we might need more complex logic,
      // but for V2 MVP, we'll schedule for the next occurrence.
      if (alarm.repeatDays.isNotEmpty) {
        // Find next day in repeatDays
        // This is a simplified version
        while (!alarm.repeatDays.contains(_getDayName(scheduledDate.weekday))) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
      }

      final androidDetails = AndroidNotificationDetails(
        'alarm_channel',
        'Alarms',
        channelDescription: 'Channel for alarm notifications',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        sound: _getSound(alarm.soundPath),
        playSound: true,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        id: alarm.id.hashCode,
        title: 'Alarm',
        body: alarm.label ?? 'Time to wake up!',
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Notification scheduled for: $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  AndroidNotificationSound? _getSound(String soundPath) {
    if (soundPath == 'default') return null;
    if (soundPath.startsWith('/')) {
      // Custom file path (this might need specific URI handling depending on plugin version)
      return UriAndroidNotificationSound(soundPath);
    }
    // Predefined sounds in res/raw
    return RawResourceAndroidNotificationSound(soundPath.split('.').first);
  }

  Future<void> cancelAlarm(String alarmId) async {
    await _notificationsPlugin.cancel(id: alarmId.hashCode);
  }
}
