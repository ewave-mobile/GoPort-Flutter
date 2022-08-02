// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ShipResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipResponse _$ShipResponseFromJson(Map<String, dynamic> json) {
  return ShipResponse(
    (json['shipsList'] as List)
        ?.map(
            (e) => e == null ? null : Ship.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ShipResponseToJson(ShipResponse instance) =>
    <String, dynamic>{
      'shipsList': instance.shipsList,
    };
