import 'package:goport/Models/PortContainer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'NotTakePhotoReason.g.dart';

@JsonSerializable()
class NotTakePhotoReason {
  final int id;
  final String description;

  NotTakePhotoReason({required this.id, required this.description});

  factory NotTakePhotoReason.fromJson(Map<String, dynamic> json) =>
      _$NotTakePhotoReasonFromJson(json);
  Map<String, dynamic> toJson() => _$NotTakePhotoReasonToJson(this);
}
