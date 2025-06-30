// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DraftJobCard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftJobCard _$DraftJobCardFromJson(Map<String, dynamic> json) => DraftJobCard(
      id: (json['id'] as num).toInt(),
      driverTZ: json['driverTZ'] as String?,
      containerNo: json['containerNo'] as String?,
      createDate: json['createDate'] == null
          ? null
          : DateTime.parse(json['createDate'] as String),
      containerJobTypeID: (json['containerJobTypeID'] as num?)?.toInt(),
      plombaNumber: json['plombaNumber'] as String?,
      imagePath: json['imagePath'] as String?,
      imageName: json['imageName'] as String?,
      image: json['image'] as String?,
      notTakePhotoReasonID: (json['notTakePhotoReasonID'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DraftJobCardToJson(DraftJobCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverTZ': instance.driverTZ,
      'containerNo': instance.containerNo,
      'createDate': instance.createDate?.toIso8601String(),
      'containerJobTypeID': instance.containerJobTypeID,
      'plombaNumber': instance.plombaNumber,
      'imagePath': instance.imagePath,
      'imageName': instance.imageName,
      'image': instance.image,
      'notTakePhotoReasonID': instance.notTakePhotoReasonID,
    };
