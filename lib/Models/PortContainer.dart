import 'package:json_annotation/json_annotation.dart';
part 'PortContainer.g.dart';

@JsonSerializable()
class PortContainer {
  int id;
  String? actualCntrNo;
  String? containerType;
  double? weight;
  String? fullEmptyContainer;
  String? bay;
  String? ca;
  String? size;
  String? block;
  String? declaredSealNo;
  String? informationStatus;
  String? pickUpPlanTime;
  String? pickUpPlanTime2;
  String? remarks;
  String? positionContainer;
  String? shipperCompanyName;
  String? shippingAgent;
  String? sealNo;
  int? draftID;
  String? plombaNumber;
  String? imagePath;
  String? imageName;
  String? image;
  String? lat;
  String? lng;
  String? deliveryDocType;
  String? cargoType;

  PortContainer(
      {required this.id,
      this.actualCntrNo,
      this.containerType,
      this.weight,
      this.fullEmptyContainer,
      this.bay,
      this.ca,
      this.size,
      this.block,
      this.declaredSealNo,
      this.informationStatus,
      this.pickUpPlanTime,
      this.pickUpPlanTime2,
      this.remarks,
      this.positionContainer,
      this.shipperCompanyName,
      this.shippingAgent,
      this.sealNo,
      this.draftID,
      this.plombaNumber,
      this.imagePath,
      this.imageName,
      this.image,
      this.lat,
      this.lng,
      this.deliveryDocType,
      this.cargoType});

  factory PortContainer.fromJson(Map<String, dynamic> json) =>
      _$PortContainerFromJson(json);
  Map<String, dynamic> toJson() => _$PortContainerToJson(this);
}
