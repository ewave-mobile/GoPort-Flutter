import 'package:json_annotation/json_annotation.dart';
part 'Ship.g.dart';

@JsonSerializable()
class Ship {
  String? ship_NO; //shipNo
  String? shipnamE_ENG; //shipName
  String? stat; //status
  String? sochen; //agent
  String? razif; //dock
  String? lasT_UPDATE; //lastUpdate
  String? x_GPS; //lat
  String? y_GPS; //lng
  String? zakef;
  bool? selected;

  Ship(this.ship_NO, this.shipnamE_ENG, this.stat, this.sochen, this.razif,
      this.lasT_UPDATE, this.x_GPS, this.y_GPS, this.zakef, this.selected);

  factory Ship.fromJson(Map<String, dynamic> json) => _$ShipFromJson(json);
  Map<String, dynamic> toJson() => _$ShipToJson(this);
}
