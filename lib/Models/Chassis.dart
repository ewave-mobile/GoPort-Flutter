import 'package:json_annotation/json_annotation.dart';
part 'Chassis.g.dart';

@JsonSerializable()
class Chassis {
  int id;
  String importer;
  String chassisID;
  String manufacturer;
  String model;
  String location;
  double lat;
  double lng;
  int chassisStatusID;
  bool hasDamageReported;
  String destination;
  String shipmentID;
  String guidID;
  DateTime createDate;
  DateTime lastUpdate;
  DateTime reportDate;
  bool isLoaded;

  Chassis(
  {this.id,
      this.importer,
      this.chassisID,
      this.manufacturer,
      this.model,
      this.location,
      this.lat,
      this.lng,
      this.chassisStatusID,
      this.hasDamageReported,
      this.destination,
      this.shipmentID,
      this.guidID,
      this.createDate,
      this.lastUpdate,
      this.reportDate,
      this.isLoaded});

  factory Chassis.fromJson(Map<String, dynamic> json) => _$ChassisFromJson(json);
  Map<String, dynamic> toJson() => _$ChassisToJson(this);

}
