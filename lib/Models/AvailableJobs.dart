import 'package:goport/Models/PortContainer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'AvailableJobs.g.dart';

@JsonSerializable()
class AvailableJobs {
  @JsonKey(defaultValue: [] )
  List<PortContainer> containerJobsIn = [];

  @JsonKey(defaultValue: [] )
  List<PortContainer> containerJobsOut = [];

  AvailableJobs(
      {required this.containerJobsIn, required this.containerJobsOut});

  factory AvailableJobs.fromJson(Map<String, dynamic> json) =>
      _$AvailableJobsFromJson(json);
  Map<String, dynamic> toJson() => _$AvailableJobsToJson(this);
}
