import 'package:goport/Models/Warehouse.dart';
import 'package:json_annotation/json_annotation.dart';
part 'WarehouseResponse.g.dart';

@JsonSerializable()
class WarehouseResponse {
  List<Warehouse> machsanList;

  WarehouseResponse(this.machsanList); //warehouses

  factory WarehouseResponse.fromJson(Map<String, dynamic> json) => _$WarehouseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WarehouseResponseToJson(this);
}