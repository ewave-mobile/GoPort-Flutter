// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'VehicleDetails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleDetails _$VehicleDetailsFromJson(Map<String, dynamic> json) =>
    VehicleDetails(
      Truck.fromJson(json['truck'] as Map<String, dynamic>),
      Truck.fromJson(json['trailer'] as Map<String, dynamic>),
      json['blockReason'] as String,
      json['isBlock'] as bool,
    );

Map<String, dynamic> _$VehicleDetailsToJson(VehicleDetails instance) =>
    <String, dynamic>{
      'truck': instance.truck,
      'trailer': instance.trailer,
      'blockReason': instance.blockReason,
      'isBlock': instance.isBlock,
    };
