import 'package:goport/Models/PortContainer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ChargeException.g.dart';

@JsonSerializable()
class ChargeException {
  int? id;
  String? driverTZ;
  String? driverName;
  String? companyName;
  String? containerNum;
  String? truckNum;
  String? trailerNum;
  bool? sealNotMatch;
  String? sealNotMatchDeclared;
  String? sealNotMatchActually;
  bool? weightMismatched;
  String? weightMismatchedDeclared;
  String? weightMismatchedActually;
  bool? goodsMismatched;
  String? goodsMismatchedRemark;
  String? signatureFileName;
  String? signature;
  DateTime? createDate;

  ChargeException(
      {this.id,
      this.driverTZ,
      this.driverName,
      this.companyName,
      this.containerNum,
      this.truckNum,
      this.trailerNum,
      this.sealNotMatch,
      this.sealNotMatchDeclared,
      this.sealNotMatchActually,
      this.weightMismatched,
      this.weightMismatchedDeclared,
      this.weightMismatchedActually,
      this.goodsMismatched,
      this.goodsMismatchedRemark,
      this.signatureFileName,
      this.signature,
      this.createDate});

  factory ChargeException.fromJson(Map<String, dynamic> json) =>
      _$ChargeExceptionFromJson(json);

  Map<String, dynamic> toJson() => _$ChargeExceptionToJson(this);
}
