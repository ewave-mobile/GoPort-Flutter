import 'package:goport/Models/PortContainer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'JobCard.g.dart';

@JsonSerializable()
class JobCard {
  int? id;
  String? guidID;
  double? allowedWeightTruck;
  double? totalWeight;
  DateTime? createDate;
  bool? approved = false;
  List<PortContainer>? containerJobsIn = [];
  List<PortContainer>? containerJobsOut = [];

  JobCard(
      {this.id,
      this.guidID,
      this.allowedWeightTruck,
      this.totalWeight,
      this.createDate,
      this.approved,
      this.containerJobsIn,
      this.containerJobsOut});

  factory JobCard.fromJson(Map<String, dynamic> json) =>
      _$JobCardFromJson(json);

  Map<String, dynamic> toJson() => _$JobCardToJson(this);
}
