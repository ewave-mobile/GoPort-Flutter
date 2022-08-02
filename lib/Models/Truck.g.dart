// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Truck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Truck _$TruckFromJson(Map<String, dynamic> json) {
  return Truck(
    json['num'] as String,
    json['licenseNumber'] as String,
    json['vehicleType'] as int,
    json['vehicleType_N'] as String,
    json['blockType'] as int,
    json['blocktype_n'] as String,
    json['companyNumber'] as int,
    json['isByPass'] as bool,
  );
}

Map<String, dynamic> _$TruckToJson(Truck instance) => <String, dynamic>{
      'num': instance.num,
      'licenseNumber': instance.licenseNumber,
      'vehicleType': instance.vehicleType,
      'vehicleType_N': instance.vehicleType_N,
      'blockType': instance.blockType,
      'blocktype_n': instance.blocktype_n,
      'companyNumber': instance.companyNumber,
      'isByPass': instance.isByPass,
    };
