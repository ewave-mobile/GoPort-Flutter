// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ShipResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipResponse _$ShipResponseFromJson(Map<String, dynamic> json) => ShipResponse(
      (json['shipsList'] as List<dynamic>)
          .map((e) => Ship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ShipResponseToJson(ShipResponse instance) =>
    <String, dynamic>{
      'shipsList': instance.shipsList,
    };
