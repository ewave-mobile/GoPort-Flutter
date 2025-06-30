// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SaveContainersToDraft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveContainersToDraft _$SaveContainersToDraftFromJson(
        Map<String, dynamic> json) =>
    SaveContainersToDraft(
      driverTZ: json['driverTZ'] as String,
      containersToAdd: (json['containersToAdd'] as List<dynamic>)
          .map((e) => DraftJobCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaveContainersToDraftToJson(
        SaveContainersToDraft instance) =>
    <String, dynamic>{
      'driverTZ': instance.driverTZ,
      'containersToAdd': instance.containersToAdd,
    };
