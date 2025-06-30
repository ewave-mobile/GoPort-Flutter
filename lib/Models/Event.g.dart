// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      (json['iruaCode'] as num).toInt(),
      json['sugIruaName'] as String,
      json['iruaTeur'] as String,
      json['iruaPtichaDate'] == null
          ? null
          : DateTime.parse(json['iruaPtichaDate'] as String),
      json['iruaSgiraDate'] == null
          ? null
          : DateTime.parse(json['iruaSgiraDate'] as String),
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'iruaCode': instance.iruaCode,
      'sugIruaName': instance.sugIruaName,
      'iruaTeur': instance.iruaTeur,
      'iruaPtichaDate': instance.iruaPtichaDate?.toIso8601String(),
      'iruaSgiraDate': instance.iruaSgiraDate?.toIso8601String(),
    };
