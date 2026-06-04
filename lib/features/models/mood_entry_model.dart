import 'package:hive/hive.dart';

part 'mood_entry_model.g.dart';

@HiveType(typeId: 1)
class MoodEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String mood; // emoji or identifier

  @HiveField(2)
  String note;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  String? title;

  MoodEntryModel({
    required this.id,
    required this.mood,
    required this.note,
    required this.createdAt,
    this.title,
  });
}
