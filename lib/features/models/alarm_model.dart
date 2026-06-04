import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 0)
class AlarmModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  int hour;

  @HiveField(2)
  int minute;

  @HiveField(3)
  String soundPath;

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  List<String> repeatDays; // ["Monday", "Tuesday", ...]

  @HiveField(6)
  int snoozeDuration; // in minutes

  @HiveField(7)
  int maxSnoozes;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  String? label;

  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.soundPath = 'default',
    this.isEnabled = true,
    this.repeatDays = const [],
    this.snoozeDuration = 5,
    this.maxSnoozes = 3,
    required this.createdAt,
    required this.updatedAt,
    this.label,
  });

  String get timeFormatted {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }
}
