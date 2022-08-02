// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ImporterChassis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImporterChassis _$ImporterChassisFromJson(Map<String, dynamic> json) {
  return ImporterChassis(
    importer: json['importer'] as String,
    manufacturer: json['manufacturer'] as String,
    model: json['model'] as String,
    location: json['location'] as String,
    destination: json['destination'] as String,
    qty: json['qty'] as int,
    selected: json['selected'] as bool,
  );
}

Map<String, dynamic> _$ImporterChassisToJson(ImporterChassis instance) =>
    <String, dynamic>{
      'importer': instance.importer,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'location': instance.location,
      'destination': instance.destination,
      'qty': instance.qty,
      'selected': instance.selected,
    };
