// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmModelAdapter extends TypeAdapter<AlarmModel> {
  @override
  final int typeId = 0;

  @override
  AlarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmModel(
      id: fields[0] as String,
      hour: fields[1] as int,
      minute: fields[2] as int,
      soundPath: fields[3] as String,
      isEnabled: fields[4] as bool,
      repeatDays: (fields[5] as List).cast<String>(),
      snoozeDuration: fields[6] as int,
      maxSnoozes: fields[7] as int,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      label: fields[10] as String?,
      routineTasks: (fields[11] as List).cast<RoutineTask>(),
      routineReminderSoundPath: fields[12] as String,
      challengeType: fields[13] as ChallengeType,
      stepGoal: fields[14] as int,
      barcodeData: fields[15] as String?,
      referencePhotoPath: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.hour)
      ..writeByte(2)
      ..write(obj.minute)
      ..writeByte(3)
      ..write(obj.soundPath)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.repeatDays)
      ..writeByte(6)
      ..write(obj.snoozeDuration)
      ..writeByte(7)
      ..write(obj.maxSnoozes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.label)
      ..writeByte(11)
      ..write(obj.routineTasks)
      ..writeByte(12)
      ..write(obj.routineReminderSoundPath)
      ..writeByte(13)
      ..write(obj.challengeType)
      ..writeByte(14)
      ..write(obj.stepGoal)
      ..writeByte(15)
      ..write(obj.barcodeData)
      ..writeByte(16)
      ..write(obj.referencePhotoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeTypeAdapter extends TypeAdapter<ChallengeType> {
  @override
  final int typeId = 6;

  @override
  ChallengeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeType.numberOrder;
      case 1:
        return ChallengeType.memorySequence;
      case 2:
        return ChallengeType.matchPairs;
      case 3:
        return ChallengeType.sequencePath;
      case 4:
        return ChallengeType.patternMemory;
      case 5:
        return ChallengeType.typing;
      case 6:
        return ChallengeType.stepCounter;
      case 7:
        return ChallengeType.math;
      case 8:
        return ChallengeType.barcodeScanner;
      case 9:
        return ChallengeType.photoMatch;
      default:
        return ChallengeType.numberOrder;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeType obj) {
    switch (obj) {
      case ChallengeType.numberOrder:
        writer.writeByte(0);
        break;
      case ChallengeType.memorySequence:
        writer.writeByte(1);
        break;
      case ChallengeType.matchPairs:
        writer.writeByte(2);
        break;
      case ChallengeType.sequencePath:
        writer.writeByte(3);
        break;
      case ChallengeType.patternMemory:
        writer.writeByte(4);
        break;
      case ChallengeType.typing:
        writer.writeByte(5);
        break;
      case ChallengeType.stepCounter:
        writer.writeByte(6);
        break;
      case ChallengeType.math:
        writer.writeByte(7);
        break;
      case ChallengeType.barcodeScanner:
        writer.writeByte(8);
        break;
      case ChallengeType.photoMatch:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
