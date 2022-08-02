import 'package:goport/Models/DraftJobCard.dart';
import 'package:json_annotation/json_annotation.dart';
part 'SaveContainersToDraft.g.dart';

@JsonSerializable()
class SaveContainersToDraft {
  final String driverTZ;
  final List<DraftJobCard> containersToAdd;

  SaveContainersToDraft({this.driverTZ, this.containersToAdd});

  factory SaveContainersToDraft.fromJson(Map<String, dynamic> json) => _$SaveContainersToDraftFromJson(json);
  Map<String, dynamic> toJson() => _$SaveContainersToDraftToJson(this);

}
