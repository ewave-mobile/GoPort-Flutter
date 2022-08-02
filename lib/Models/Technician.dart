import 'package:json_annotation/json_annotation.dart';
part 'Technician.g.dart';
@JsonSerializable()
class Technician {
  int id;
  String containerTypeID;
  String technicianName;
  String phoneNumber;
  String address;

  Technician(this.id, this.containerTypeID, this.technicianName,
      this.phoneNumber, this.address);

  factory Technician.fromJson(Map<String, dynamic> json) => _$TechnicianFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicianToJson(this);
}