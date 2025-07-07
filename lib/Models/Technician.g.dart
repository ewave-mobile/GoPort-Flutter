// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Technician.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Technician _$TechnicianFromJson(Map<String, dynamic> json) => Technician(
      (json['id'] as num).toInt(),
      json['containerTypeID'] as String?,
      json['technicianName'] as String?,
      json['phoneNumber'] as String?,
      json['address'] as String?,
    );

Map<String, dynamic> _$TechnicianToJson(Technician instance) =>
    <String, dynamic>{
      'id': instance.id,
      'containerTypeID': instance.containerTypeID,
      'technicianName': instance.technicianName,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
    };
