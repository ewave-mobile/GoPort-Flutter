// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AvailableJobs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableJobs _$AvailableJobsFromJson(Map<String, dynamic> json) =>
    AvailableJobs(
      containerJobsIn: (json['containerJobsIn'] as List<dynamic>?)
              ?.map((e) => PortContainer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      containerJobsOut: (json['containerJobsOut'] as List<dynamic>?)
              ?.map((e) => PortContainer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$AvailableJobsToJson(AvailableJobs instance) =>
    <String, dynamic>{
      'containerJobsIn': instance.containerJobsIn,
      'containerJobsOut': instance.containerJobsOut,
    };
