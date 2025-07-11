import 'package:goport/Models/Truck.dart';
import 'package:json_annotation/json_annotation.dart';
part 'VehicleDetails.g.dart';

@JsonSerializable()
class VehicleDetails {
  String? blockReason;
  bool? isBlock;
  Truck? truck;
  Truck? trailer;


  VehicleDetails(this.truck, this.trailer, this.blockReason, this.isBlock);

  factory VehicleDetails.fromJson(Map<String, dynamic> json) =>
      _$VehicleDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleDetailsToJson(this);
}
