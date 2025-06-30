import 'package:json_annotation/json_annotation.dart';
part 'GoPortAppStatus.g.dart';

@JsonSerializable()
class GoPortAppStatus {
  final int id;
  final String? driverTZ;
  final String? guidID;
  final String? truckNum;
  final String? trailerNum;
  final bool? appInForeground;
  final bool? driverAccepted;
  final DateTime? timeStamp;

  GoPortAppStatus(
      {required this.id,
      this.driverTZ,
      this.guidID,
      this.truckNum,
      this.trailerNum,
      this.appInForeground,
      this.driverAccepted,
      this.timeStamp});

  factory GoPortAppStatus.fromJson(Map<String, dynamic> json) =>
      _$GoPortAppStatusFromJson(json);
  Map<String, dynamic> toJson() => _$GoPortAppStatusToJson(this);
}
