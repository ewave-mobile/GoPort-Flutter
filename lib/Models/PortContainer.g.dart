// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PortContainer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortContainer _$PortContainerFromJson(Map<String, dynamic> json) =>
    PortContainer(
      id: (json['id'] as num?)?.toInt(),
      actualCntrNo: json['actualCntrNo'] as String?,
      containerType: json['containerType'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      fullEmptyContainer: json['fullEmptyContainer'] as String?,
      bay: json['bay'] as String?,
      ca: json['ca'] as String?,
      size: json['size'] as String?,
      block: json['block'] as String?,
      declaredSealNo: json['declaredSealNo'] as String?,
      informationStatus: json['informationStatus'] as String?,
      pickUpPlanTime: json['pickUpPlanTime'] as String?,
      pickUpPlanTime2: json['pickUpPlanTime2'] as String?,
      remarks: json['remarks'] as String?,
      positionContainer: json['positionContainer'] as String?,
      shipperCompanyName: json['shipperCompanyName'] as String?,
      shippingAgent: json['shippingAgent'] as String?,
      sealNo: json['sealNo'] as String?,
      draftID: (json['draftID'] as num?)?.toInt(),
      plombaNumber: json['plombaNumber'] as String?,
      imagePath: json['imagePath'] as String?,
      imageName: json['imageName'] as String?,
      image: json['image'] as String?,
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      deliveryDocType: json['deliveryDocType'] as String?,
      cargoType: json['cargoType'] as String?,
    );

Map<String, dynamic> _$PortContainerToJson(PortContainer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actualCntrNo': instance.actualCntrNo,
      'containerType': instance.containerType,
      'weight': instance.weight,
      'fullEmptyContainer': instance.fullEmptyContainer,
      'bay': instance.bay,
      'ca': instance.ca,
      'size': instance.size,
      'block': instance.block,
      'declaredSealNo': instance.declaredSealNo,
      'informationStatus': instance.informationStatus,
      'pickUpPlanTime': instance.pickUpPlanTime,
      'pickUpPlanTime2': instance.pickUpPlanTime2,
      'remarks': instance.remarks,
      'positionContainer': instance.positionContainer,
      'shipperCompanyName': instance.shipperCompanyName,
      'shippingAgent': instance.shippingAgent,
      'sealNo': instance.sealNo,
      'draftID': instance.draftID,
      'plombaNumber': instance.plombaNumber,
      'imagePath': instance.imagePath,
      'imageName': instance.imageName,
      'image': instance.image,
      'lat': instance.lat,
      'lng': instance.lng,
      'deliveryDocType': instance.deliveryDocType,
      'cargoType': instance.cargoType,
    };
