import 'package:json_annotation/json_annotation.dart';
part 'Truck.g.dart';

@JsonSerializable()
class Truck {
  String? num;
  String? licenseNumber;
  int? vehicleType;
  String? vehicleType_N;
  int? blockType;
  String? blocktype_n; //blockReason
  int? companyNumber;
  bool? isByPass;

  Truck(this.num, this.licenseNumber, this.vehicleType, this.vehicleType_N,
      this.blockType, this.blocktype_n, this.companyNumber, this.isByPass);

  factory Truck.fromJson(Map<String, dynamic> json) => _$TruckFromJson(json);
  Map<String, dynamic> toJson() => _$TruckToJson(this);
}
