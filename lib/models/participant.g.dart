// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParticipantAdapter extends TypeAdapter<Participant> {
  @override
  final int typeId = 2;

  @override
  Participant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Participant(
      name: fields[0] as String,
      rapidTests: fields[1] as int,
      precisionTests: fields[2] as int,
      rapidPoints: fields[3] as int,
      precisionPoints: fields[4] as int,
      totalPoints: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Participant obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.rapidTests)
      ..writeByte(2)
      ..write(obj.precisionTests)
      ..writeByte(3)
      ..write(obj.rapidPoints)
      ..writeByte(4)
      ..write(obj.precisionPoints)
      ..writeByte(5)
      ..write(obj.totalPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
