import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'routine_task_model.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 6)
enum ChallengeType {
  @HiveField(0)
  numberOrder,
  @HiveField(1)
  memorySequence,
  @HiveField(2)
  matchPairs,
  @HiveField(3)
  sequencePath,
  @HiveField(4)
  patternMemory,
  @HiveField(5)
  typing,
  @HiveField(6)
  stepCounter,
  @HiveField(7)
  math,
  @HiveField(8)
  barcodeScanner,
  @HiveField(9)
  photoMatch,
}

extension ChallengeTypeExtension on ChallengeType {
  String get label {
    switch (this) {
      case ChallengeType.numberOrder: return 'Number Order';
      case ChallengeType.memorySequence: return 'Memory Sequence';
      case ChallengeType.matchPairs: return 'Match Pairs';
      case ChallengeType.sequencePath: return 'Sequence Path';
      case ChallengeType.patternMemory: return 'Pattern Memory';
      case ChallengeType.typing: return 'Typing';
      case ChallengeType.stepCounter: return 'Step Counter';
      case ChallengeType.math: return 'Math Challenge';
      case ChallengeType.barcodeScanner: return 'Barcode Scanner';
      case ChallengeType.photoMatch: return 'Photo Match';
    }
  }

  IconData get icon {
    switch (this) {
      case ChallengeType.numberOrder: return Icons.format_list_numbered_rounded;
      case ChallengeType.memorySequence: return Icons.reorder_rounded;
      case ChallengeType.matchPairs: return Icons.grid_view_rounded;
      case ChallengeType.sequencePath: return Icons.gesture_rounded;
      case ChallengeType.patternMemory: return Icons.apps_rounded;
      case ChallengeType.typing: return Icons.keyboard_rounded;
      case ChallengeType.stepCounter: return Icons.directions_walk_rounded;
      case ChallengeType.math: return Icons.calculate_rounded;
      case ChallengeType.barcodeScanner: return Icons.qr_code_scanner_rounded;
      case ChallengeType.photoMatch: return Icons.camera_alt_rounded;
    }
  }
}

// Represents the core data model for a user-defined alarm
@HiveType(typeId: 0)
class AlarmModel extends HiveObject {
  @HiveField(0)
  final String id; // Unique UUID string

  @HiveField(1)
  int hour; // 24-hour format

  @HiveField(2)
  int minute;

  @HiveField(3)
  String soundPath; // Path to the audio asset or device file

  @HiveField(4)
  bool isEnabled; // Whether the alarm is currently scheduled to ring

  @HiveField(5)
  List<String> repeatDays; // Days of the week the alarm should trigger

  @HiveField(6)
  int snoozeDuration; // Minutes to wait before ringing again after snooze

  @HiveField(7)
  int maxSnoozes; // Limit to prevent infinite snoozing

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  String? label; // Custom user-defined name for the alarm

  @HiveField(11)
  List<RoutineTask> routineTasks; // Sequence of tasks for the morning flow

  @HiveField(12)
  String routineReminderSoundPath; // Audio for the routine notification

  @HiveField(13)
  ChallengeType challengeType;

  @HiveField(14)
  int stepGoal;

  @HiveField(15)
  String? barcodeData;

  @HiveField(16)
  String? referencePhotoPath;

  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.soundPath = 'assets/sounds/alarm.mp3',
    this.isEnabled = true,
    this.repeatDays = const [],
    this.snoozeDuration = 5,
    this.maxSnoozes = 3,
    required this.createdAt,
    required this.updatedAt,
    this.label,
    this.routineTasks = const [],
    this.routineReminderSoundPath = 'default',
    this.challengeType = ChallengeType.memorySequence,
    this.stepGoal = 10,
    this.barcodeData,
    this.referencePhotoPath,
  });

  // Returns a formatted string for UI display (e.g., "07:30 AM")
  String get timeFormatted {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }
}
