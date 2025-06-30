// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DriverGpsTracking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverGpsTracking _$DriverGpsTrackingFromJson(Map<String, dynamic> json) =>
    DriverGpsTracking(
      id: (json['id'] as num?)?.toInt(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      serialNumber: json['serialNumber'] as String?,
      trackingDate: json['trackingDate'] == null
          ? null
          : DateTime.parse(json['trackingDate'] as String),
    );

Map<String, dynamic> _$DriverGpsTrackingToJson(DriverGpsTracking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lat': instance.lat,
      'lng': instance.lng,
      'serialNumber': instance.serialNumber,
      'trackingDate': instance.trackingDate?.toIso8601String(),
    };
