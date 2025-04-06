// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Chassis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chassis _$ChassisFromJson(Map<String, dynamic> json) => Chassis(
      id: (json['id'] as num).toInt(),
      importer: json['importer'] as String?,
      chassisID: json['chassisID'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      location: json['location'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      chassisStatusID: (json['chassisStatusID'] as num?)?.toInt(),
      hasDamageReported: json['hasDamageReported'] as bool?,
      destination: json['destination'] as String?,
      shipmentID: json['shipmentID'] as String?,
      guidID: json['guidID'] as String?,
      createDate: json['createDate'] == null
          ? null
          : DateTime.parse(json['createDate'] as String),
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
      reportDate: json['reportDate'] == null
          ? null
          : DateTime.parse(json['reportDate'] as String),
      isLoaded: json['isLoaded'] as bool?,
    );

Map<String, dynamic> _$ChassisToJson(Chassis instance) => <String, dynamic>{
      'id': instance.id,
      'importer': instance.importer,
      'chassisID': instance.chassisID,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'location': instance.location,
      'lat': instance.lat,
      'lng': instance.lng,
      'chassisStatusID': instance.chassisStatusID,
      'hasDamageReported': instance.hasDamageReported,
      'destination': instance.destination,
      'shipmentID': instance.shipmentID,
      'guidID': instance.guidID,
      'createDate': instance.createDate?.toIso8601String(),
      'lastUpdate': instance.lastUpdate?.toIso8601String(),
      'reportDate': instance.reportDate?.toIso8601String(),
      'isLoaded': instance.isLoaded,
    };
