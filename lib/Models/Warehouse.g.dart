// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Warehouse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Warehouse _$WarehouseFromJson(Map<String, dynamic> json) {
  return Warehouse(
    json['shemMachsan'] as String,
    json['x_GPS'] as String,
    json['y_GPS'] as String,
    json['selected'] as bool,
  );
}

Map<String, dynamic> _$WarehouseToJson(Warehouse instance) => <String, dynamic>{
      'shemMachsan': instance.shemMachsan,
      'x_GPS': instance.x_GPS,
      'y_GPS': instance.y_GPS,
      'selected': instance.selected,
    };
