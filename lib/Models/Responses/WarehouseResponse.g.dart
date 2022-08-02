// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WarehouseResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarehouseResponse _$WarehouseResponseFromJson(Map<String, dynamic> json) {
  return WarehouseResponse(
    (json['machsanList'] as List)
        ?.map((e) =>
            e == null ? null : Warehouse.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$WarehouseResponseToJson(WarehouseResponse instance) =>
    <String, dynamic>{
      'machsanList': instance.machsanList,
    };
