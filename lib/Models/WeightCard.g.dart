// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WeightCard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightCard _$WeightCardFromJson(Map<String, dynamic> json) => WeightCard(
      (json['id'] as num).toInt(),
      json['guidID'] as String,
      (json['grossWeightTruck'] as num).toDouble(),
      (json['grossWeightTrailer'] as num).toDouble(),
      (json['grossWeightTotal'] as num).toDouble(),
      (json['calculatedWeightTruck'] as num).toDouble(),
      (json['calculatedWeightTrailer'] as num).toDouble(),
      (json['calculatedWeightTotal'] as num).toDouble(),
      json['isOverweightTruck'] as bool,
      json['isOverweightTrailer'] as bool,
      json['isOverweightTotal'] as bool,
      (json['allowedWeightTruck'] as num).toDouble(),
      (json['allowedWeightTrailer'] as num).toDouble(),
      (json['totalAllowedWeight'] as num).toDouble(),
      (json['manualGrossWeightTruck'] as num).toDouble(),
      (json['manualGrossWeightTrailer'] as num).toDouble(),
      (json['manualGrossWeightTotal'] as num).toDouble(),
      DateTime.parse(json['weightTime'] as String),
      DateTime.parse(json['createDate'] as String),
    );

Map<String, dynamic> _$WeightCardToJson(WeightCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guidID': instance.guidID,
      'grossWeightTruck': instance.grossWeightTruck,
      'grossWeightTrailer': instance.grossWeightTrailer,
      'grossWeightTotal': instance.grossWeightTotal,
      'calculatedWeightTruck': instance.calculatedWeightTruck,
      'calculatedWeightTrailer': instance.calculatedWeightTrailer,
      'calculatedWeightTotal': instance.calculatedWeightTotal,
      'isOverweightTruck': instance.isOverweightTruck,
      'isOverweightTrailer': instance.isOverweightTrailer,
      'isOverweightTotal': instance.isOverweightTotal,
      'allowedWeightTruck': instance.allowedWeightTruck,
      'allowedWeightTrailer': instance.allowedWeightTrailer,
      'totalAllowedWeight': instance.totalAllowedWeight,
      'manualGrossWeightTruck': instance.manualGrossWeightTruck,
      'manualGrossWeightTrailer': instance.manualGrossWeightTrailer,
      'manualGrossWeightTotal': instance.manualGrossWeightTotal,
      'weightTime': instance.weightTime.toIso8601String(),
      'createDate': instance.createDate.toIso8601String(),
    };
