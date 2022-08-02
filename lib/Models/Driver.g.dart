// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) {
  return Driver(
    id: json['id'] as int,
    tz: json['tz'] as String,
    firstName: json['firstName'] as String,
    idNumber: json['idNumber'] as String,
    lastName: json['lastName'] as String,
    autoLaneAuthorization: json['autoLaneAuthorization'] as bool,
    phoneNumber: json['phoneNumber'] as String,
    populationType: json['populationType'] as int,
    companyName: json['companyName'] as String,
    companyNumber: json['companyNumber'] as int,
    blockType: json['blockType'] as int,
    blockReason: json['blockReason'] as String,
  );
}

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'id': instance.id,
      'tz': instance.tz,
      'firstName': instance.firstName,
      'idNumber': instance.idNumber,
      'lastName': instance.lastName,
      'autoLaneAuthorization': instance.autoLaneAuthorization,
      'phoneNumber': instance.phoneNumber,
      'populationType': instance.populationType,
      'companyName': instance.companyName,
      'companyNumber': instance.companyNumber,
      'blockType': instance.blockType,
      'blockReason': instance.blockReason,
    };
