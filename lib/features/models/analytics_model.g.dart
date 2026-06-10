// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmAnalyticsAdapter extends TypeAdapter<AlarmAnalytics> {
  @override
  final int typeId = 3;

  @override
  AlarmAnalytics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmAnalytics(
      id: fields[0] as String,
      alarmTime: fields[1] as DateTime,
      actualWakeUpTime: fields[2] as DateTime,
      wakeUpDelayMinutes: fields[3] as int,
      snoozeCount: fields[4] as int,
      date: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmAnalytics obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.alarmTime)
      ..writeByte(2)
      ..write(obj.actualWakeUpTime)
      ..writeByte(3)
      ..write(obj.wakeUpDelayMinutes)
      ..writeByte(4)
      ..write(obj.snoozeCount)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAnalyticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutineAnalyticsAdapter extends TypeAdapter<RoutineAnalytics> {
  @override
  final int typeId = 4;

  @override
  RoutineAnalytics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineAnalytics(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
      additionalTimeMinutes: fields[4] as int,
      date: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineAnalytics obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.additionalTimeMinutes)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineAnalyticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeAnalyticsAdapter extends TypeAdapter<ChallengeAnalytics> {
  @override
  final int typeId = 5;

  @override
  ChallengeAnalytics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeAnalytics(
      id: fields[0] as String,
      type: fields[1] as String,
      wasSuccessful: fields[2] as bool,
      levelReached: fields[3] as int,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeAnalytics obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.wasSuccessful)
      ..writeByte(3)
      ..write(obj.levelReached)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeAnalyticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
