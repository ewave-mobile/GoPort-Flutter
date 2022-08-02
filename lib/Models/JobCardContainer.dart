import 'package:goport/Models/PortContainer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'JobCardContainer.g.dart';

@JsonSerializable()
class JobCardContainer  {
  final PortContainer container;
  final String guidID;

  JobCardContainer({this.container, this.guidID});

  factory JobCardContainer.fromJson(Map<String, dynamic> json) => _$JobCardContainerFromJson(json);
  Map<String, dynamic> toJson() => _$JobCardContainerToJson(this);

}
