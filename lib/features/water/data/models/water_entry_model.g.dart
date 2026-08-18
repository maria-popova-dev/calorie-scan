// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterEntryModelAdapter extends TypeAdapter<WaterEntryModel> {
  @override
  final int typeId = 2;

  @override
  WaterEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterEntryModel(
      id: fields[0] as String,
      amountMl: fields[1] as double,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WaterEntryModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amountMl)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
