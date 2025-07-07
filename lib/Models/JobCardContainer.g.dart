// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JobCardContainer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobCardContainer _$JobCardContainerFromJson(Map<String, dynamic> json) =>
    JobCardContainer(
      container:
          PortContainer.fromJson(json['container'] as Map<String, dynamic>),
      guidID: json['guidID'] as String?,
    );

Map<String, dynamic> _$JobCardContainerToJson(JobCardContainer instance) =>
    <String, dynamic>{
      'container': instance.container,
      'guidID': instance.guidID,
    };
