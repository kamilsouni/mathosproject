// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompetitionAdapter extends TypeAdapter<Competition> {
  @override
  final int typeId = 1;

  @override
  Competition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Competition(
      id: fields[0] as String,
      creatorId: fields[1] as String,
      name: fields[2] as String,
      numRapidTests: fields[3] as int,
      numProblemTests: fields[4] as int,
      participants: (fields[5] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Competition obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creatorId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.numRapidTests)
      ..writeByte(4)
      ..write(obj.numProblemTests)
      ..writeByte(5)
      ..write(obj.participants);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
