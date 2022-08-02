import 'package:json_annotation/json_annotation.dart';
part 'DriverGpsTracking.g.dart';
@JsonSerializable()
class DriverGpsTracking {
  int id;
  double lat;
  double lng;
  String serialNumber;
  DateTime trackingDate;

  DriverGpsTracking(
  {this.id, this.lat, this.lng, this.serialNumber, this.trackingDate});

  factory DriverGpsTracking.fromJson(Map<String, dynamic> json) => _$DriverGpsTrackingFromJson(json);
  Map<String, dynamic> toJson() => _$DriverGpsTrackingToJson(this);

}