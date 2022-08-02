// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'VehicleDetails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleDetails _$VehicleDetailsFromJson(Map<String, dynamic> json) {
  return VehicleDetails(
    json['truck'] == null
        ? null
        : Truck.fromJson(json['truck'] as Map<String, dynamic>),
    json['trailer'] == null
        ? null
        : Truck.fromJson(json['trailer'] as Map<String, dynamic>),
    json['blockReason'] as String,
    json['isBlock'] as bool,
  );
}

Map<String, dynamic> _$VehicleDetailsToJson(VehicleDetails instance) =>
    <String, dynamic>{
      'truck': instance.truck,
      'trailer': instance.trailer,
      'blockReason': instance.blockReason,
      'isBlock': instance.isBlock,
    };
