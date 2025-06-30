// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GoPortAppStatus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoPortAppStatus _$GoPortAppStatusFromJson(Map<String, dynamic> json) =>
    GoPortAppStatus(
      id: (json['id'] as num).toInt(),
      driverTZ: json['driverTZ'] as String?,
      guidID: json['guidID'] as String?,
      truckNum: json['truckNum'] as String?,
      trailerNum: json['trailerNum'] as String?,
      appInForeground: json['appInForeground'] as bool?,
      driverAccepted: json['driverAccepted'] as bool?,
      timeStamp: json['timeStamp'] == null
          ? null
          : DateTime.parse(json['timeStamp'] as String),
    );

Map<String, dynamic> _$GoPortAppStatusToJson(GoPortAppStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverTZ': instance.driverTZ,
      'guidID': instance.guidID,
      'truckNum': instance.truckNum,
      'trailerNum': instance.trailerNum,
      'appInForeground': instance.appInForeground,
      'driverAccepted': instance.driverAccepted,
      'timeStamp': instance.timeStamp?.toIso8601String(),
    };
