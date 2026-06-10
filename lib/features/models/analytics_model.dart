import 'package:hive/hive.dart';

part 'analytics_model.g.dart';

@HiveType(typeId: 3)
class AlarmAnalytics extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime alarmTime;

  @HiveField(2)
  final DateTime actualWakeUpTime;

  @HiveField(3)
  final int wakeUpDelayMinutes;

  @HiveField(4)
  final int snoozeCount;

  @HiveField(5)
  final DateTime date;

  AlarmAnalytics({
    required this.id,
    required this.alarmTime,
    required this.actualWakeUpTime,
    required this.wakeUpDelayMinutes,
    required this.snoozeCount,
    required this.date,
  });
}

@HiveType(typeId: 4)
class RoutineAnalytics extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final int additionalTimeMinutes;

  @HiveField(5)
  final DateTime date;

  RoutineAnalytics({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.additionalTimeMinutes,
    required this.date,
  });
}

@HiveType(typeId: 5)
class ChallengeAnalytics extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // e.g., "MemorySequence"

  @HiveField(2)
  final bool wasSuccessful;

  @HiveField(3)
  final int levelReached;

  @HiveField(4)
  final DateTime date;

  ChallengeAnalytics({
    required this.id,
    required this.type,
    required this.wasSuccessful,
    required this.levelReached,
    required this.date,
  });
}

