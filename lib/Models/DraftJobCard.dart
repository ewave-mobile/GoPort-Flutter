import 'package:json_annotation/json_annotation.dart';
part 'DraftJobCard.g.dart';

@JsonSerializable()
class DraftJobCard {
  int id;
  String? driverTZ;
  String? containerNo;
  DateTime? createDate;
  int? containerJobTypeID;
  String? plombaNumber;
  String? imagePath;
  String? imageName;
  String? image;
  int? notTakePhotoReasonID;

  DraftJobCard(
      {required this.id,
      this.driverTZ,
      this.containerNo,
      this.createDate,
      this.containerJobTypeID,
      this.plombaNumber,
      this.imagePath,
      this.imageName,
      this.image,
      this.notTakePhotoReasonID});

  factory DraftJobCard.fromJson(Map<String, dynamic> json) =>
      _$DraftJobCardFromJson(json);
  Map<String, dynamic> toJson() => _$DraftJobCardToJson(this);
}
