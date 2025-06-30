// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Ship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ship _$ShipFromJson(Map<String, dynamic> json) => Ship(
      json['ship_NO'] as String,
      json['shipnamE_ENG'] as String,
      json['stat'] as String,
      json['sochen'] as String,
      json['razif'] as String,
      json['lasT_UPDATE'] as String,
      json['x_GPS'] as String,
      json['y_GPS'] as String,
      json['zakef'] as String,
      json['selected'] as bool,
    );

Map<String, dynamic> _$ShipToJson(Ship instance) => <String, dynamic>{
      'ship_NO': instance.ship_NO,
      'shipnamE_ENG': instance.shipnamE_ENG,
      'stat': instance.stat,
      'sochen': instance.sochen,
      'razif': instance.razif,
      'lasT_UPDATE': instance.lasT_UPDATE,
      'x_GPS': instance.x_GPS,
      'y_GPS': instance.y_GPS,
      'zakef': instance.zakef,
      'selected': instance.selected,
    };
