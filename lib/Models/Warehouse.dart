import 'package:json_annotation/json_annotation.dart';
part 'Warehouse.g.dart';
@JsonSerializable()
class Warehouse {
  String shemMachsan; //warehouseName
  String x_GPS; //lat
  String y_GPS; //lng
  bool selected;

  Warehouse(this.shemMachsan, this.x_GPS, this.y_GPS, this.selected);

  factory Warehouse.fromJson(Map<String, dynamic> json) => _$WarehouseFromJson(json);
  Map<String, dynamic> toJson() => _$WarehouseToJson(this);
}
