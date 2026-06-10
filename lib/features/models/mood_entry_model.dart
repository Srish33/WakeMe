import 'package:hive/hive.dart';

part 'mood_entry_model.g.dart';

// Data model for daily mood and journal entries
@HiveType(typeId: 1)
class MoodEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String mood; // Emoji or identifier representing user's feeling

  @HiveField(2)
  String note; // Text-based journal entry

  @HiveField(3)
  final DateTime createdAt; // Date and time of the entry

  @HiveField(4)
  String? title; // Optional header for the entry

  @HiveField(5)
  List<String> audioPaths; // Paths to the recorded voice notes (m4a)

  @HiveField(6)
  List<int> audioDurationsMs; // Total durations of the recordings in milliseconds

  MoodEntryModel({
    required this.id,
    required this.mood,
    required this.note,
    required this.createdAt,
    this.title,
    this.audioPaths = const [],
    this.audioDurationsMs = const [],
  });

  // Helper to convert MS into a usable Duration object
  Duration? get audioDuration => audioDurationsMs.isNotEmpty ? Duration(milliseconds: audioDurationsMs.first) : null;
}
