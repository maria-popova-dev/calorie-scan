// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_food_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomFoodModelAdapter extends TypeAdapter<CustomFoodModel> {
  @override
  final int typeId = 1;

  @override
  CustomFoodModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomFoodModel(
      id: fields[0] as String,
      name: fields[1] as String,
      calories: fields[2] as double,
      protein: fields[3] as double,
      fat: fields[4] as double,
      carbs: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CustomFoodModel obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.carbs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomFoodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
