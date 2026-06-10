import 'package:hive/hive.dart';

part 'routine_task_model.g.dart';

// Represents an individual step in the user's morning routine
@HiveType(typeId: 2)
class RoutineTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name; // e.g., "Make Bed" or "Drink Water"

  @HiveField(2)
  int durationMinutes; // Estimated time allocated for this task

  RoutineTask({
    required this.id,
    required this.name,
    required this.durationMinutes,
  });
}
