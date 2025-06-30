import 'package:json_annotation/json_annotation.dart';
part 'Driver.g.dart';

@JsonSerializable()
class Driver {
  int? id;
  String? tz;
  String? firstName;
  String? idNumber;
  String? lastName;
  bool? autoLaneAuthorization = false;
  String? phoneNumber; //mobileNumber
  int? populationType;
  String? companyName;
  int? companyNumber;
  int? blockType;
  String? blockReason;

  Driver(
      {this.id,
      this.tz,
      this.firstName,
      this.idNumber,
      this.lastName,
      this.autoLaneAuthorization,
      this.phoneNumber,
      this.populationType,
      this.companyName,
      this.companyNumber,
      this.blockType,
      this.blockReason});

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);
}
