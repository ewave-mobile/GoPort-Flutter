// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JobCard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobCard _$JobCardFromJson(Map<String, dynamic> json) {
  return JobCard(
    id: json['id'] as int,
    guidID: json['guidID'] as String,
    allowedWeightTruck: (json['allowedWeightTruck'] as num)?.toDouble(),
    totalWeight: (json['totalWeight'] as num)?.toDouble(),
    createDate: json['createDate'] == null
        ? null
        : DateTime.parse(json['createDate'] as String),
    approved: json['approved'] as bool,
    containerJobsIn: (json['containerJobsIn'] as List)
        ?.map((e) => e == null
            ? null
            : PortContainer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    containerJobsOut: (json['containerJobsOut'] as List)
        ?.map((e) => e == null
            ? null
            : PortContainer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$JobCardToJson(JobCard instance) => <String, dynamic>{
      'id': instance.id,
      'guidID': instance.guidID,
      'allowedWeightTruck': instance.allowedWeightTruck,
      'totalWeight': instance.totalWeight,
      'createDate': instance.createDate?.toIso8601String(),
      'approved': instance.approved,
      'containerJobsIn': instance.containerJobsIn,
      'containerJobsOut': instance.containerJobsOut,
    };
