// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodEntryModelAdapter extends TypeAdapter<MoodEntryModel> {
  @override
  final int typeId = 1;

  @override
  MoodEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntryModel(
      id: fields[0] as String,
      mood: fields[1] as String,
      note: fields[2] as String,
      createdAt: fields[3] as DateTime,
      title: fields[4] as String?,
      audioPaths: (fields[5] as List).cast<String>(),
      audioDurationsMs: (fields[6] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mood)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.audioPaths)
      ..writeByte(6)
      ..write(obj.audioDurationsMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
