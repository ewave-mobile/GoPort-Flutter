import 'package:json_annotation/json_annotation.dart';
part 'WeightCard.g.dart';

@JsonSerializable()
class WeightCard {
  int id;
  String? guidID;
  double? grossWeightTruck;
  double? grossWeightTrailer;
  double? grossWeightTotal;
  double? calculatedWeightTruck;
  double? calculatedWeightTrailer;
  double? calculatedWeightTotal;
  bool? isOverweightTruck;
  bool? isOverweightTrailer;
  bool? isOverweightTotal;
  double? allowedWeightTruck;
  double? allowedWeightTrailer;
  double? totalAllowedWeight;
  double? manualGrossWeightTruck;
  double? manualGrossWeightTrailer;
  double? manualGrossWeightTotal;
  DateTime? weightTime;
  DateTime? createDate;

  WeightCard(
      this.id,
      this.guidID,
      this.grossWeightTruck,
      this.grossWeightTrailer,
      this.grossWeightTotal,
      this.calculatedWeightTruck,
      this.calculatedWeightTrailer,
      this.calculatedWeightTotal,
      this.isOverweightTruck,
      this.isOverweightTrailer,
      this.isOverweightTotal,
      this.allowedWeightTruck,
      this.allowedWeightTrailer,
      this.totalAllowedWeight,
      this.manualGrossWeightTruck,
      this.manualGrossWeightTrailer,
      this.manualGrossWeightTotal,
      this.weightTime,
      this.createDate);

  factory WeightCard.fromJson(Map<String, dynamic> json) =>
      _$WeightCardFromJson(json);
  Map<String, dynamic> toJson() => _$WeightCardToJson(this);
}
