import 'package:json_annotation/json_annotation.dart';
part 'ImporterChassis.g.dart';

@JsonSerializable()
class ImporterChassis {
  String importer;
  String manufacturer;
  String model;
  String location;
  String destination;
  int qty;
  bool selected = false;

  ImporterChassis({this.importer, this.manufacturer, this.model, this.location,
      this.destination, this.qty, this.selected = false});

  factory ImporterChassis.fromJson(Map<String, dynamic> json) => _$ImporterChassisFromJson(json);
  Map<String, dynamic> toJson() => _$ImporterChassisToJson(this);

}
