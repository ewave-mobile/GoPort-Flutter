import 'package:goport/Models/Ship.dart';
import 'package:json_annotation/json_annotation.dart';
part 'ShipResponse.g.dart';

@JsonSerializable()
class ShipResponse {
  List<Ship> shipsList;

  ShipResponse(this.shipsList);

  factory ShipResponse.fromJson(Map<String, dynamic> json) => _$ShipResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ShipResponseToJson(this);
}
