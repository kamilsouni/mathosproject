// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int,
      gender: fields[3] as String,
      email: fields[4] as String,
      points: fields[5] as int,
      flag: fields[6] as String,
      rapidTestRecord: fields[8] as int,
      precisionTestRecord: fields[9] as int,
      progression: (fields[7] as Map?)?.map((dynamic k, dynamic v) => MapEntry(
          k as int,
          (v as Map).map((dynamic k, dynamic v) =>
              MapEntry(k as String, (v as Map).cast<String, int>())))),
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.points)
      ..writeByte(6)
      ..write(obj.flag)
      ..writeByte(7)
      ..write(obj.progression)
      ..writeByte(8)
      ..write(obj.rapidTestRecord)
      ..writeByte(9)
      ..write(obj.precisionTestRecord);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
