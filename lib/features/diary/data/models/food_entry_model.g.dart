// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodEntryModelAdapter extends TypeAdapter<FoodEntryModel> {
  @override
  final int typeId = 0;

  @override
  FoodEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodEntryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      calories: fields[2] as double,
      protein: fields[3] as double,
      fat: fields[4] as double,
      carbs: fields[5] as double,
      timestamp: fields[6] as DateTime,
      sourceIndex: fields[7] as int,
      mealTypeIndex: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FoodEntryModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.protein)
      ..writeByte(4)
      ..write(obj.fat)
      ..writeByte(5)
      ..write(obj.carbs)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.sourceIndex)
      ..writeByte(8)
      ..write(obj.mealTypeIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
