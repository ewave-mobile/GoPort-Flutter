// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChargeException.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChargeException _$ChargeExceptionFromJson(Map<String, dynamic> json) {
  return ChargeException(
    id: json['id'] as int,
    driverTZ: json['driverTZ'] as String,
    driverName: json['driverName'] as String,
    companyName: json['companyName'] as String,
    containerNum: json['containerNum'] as String,
    truckNum: json['truckNum'] as String,
    trailerNum: json['trailerNum'] as String,
    sealNotMatch: json['sealNotMatch'] as bool,
    sealNotMatchDeclared: json['sealNotMatchDeclared'] as String,
    sealNotMatchActually: json['sealNotMatchActually'] as String,
    weightMismatched: json['weightMismatched'] as bool,
    weightMismatchedDeclared: json['weightMismatchedDeclared'] as String,
    weightMismatchedActually: json['weightMismatchedActually'] as String,
    goodsMismatched: json['goodsMismatched'] as bool,
    goodsMismatchedRemark: json['goodsMismatchedRemark'] as String,
    signatureFileName: json['signatureFileName'] as String,
    signature: json['signature'] as String,
    createDate: json['createDate'] == null
        ? null
        : DateTime.parse(json['createDate'] as String),
  );
}

Map<String, dynamic> _$ChargeExceptionToJson(ChargeException instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverTZ': instance.driverTZ,
      'driverName': instance.driverName,
      'companyName': instance.companyName,
      'containerNum': instance.containerNum,
      'truckNum': instance.truckNum,
      'trailerNum': instance.trailerNum,
      'sealNotMatch': instance.sealNotMatch,
      'sealNotMatchDeclared': instance.sealNotMatchDeclared,
      'sealNotMatchActually': instance.sealNotMatchActually,
      'weightMismatched': instance.weightMismatched,
      'weightMismatchedDeclared': instance.weightMismatchedDeclared,
      'weightMismatchedActually': instance.weightMismatchedActually,
      'goodsMismatched': instance.goodsMismatched,
      'goodsMismatchedRemark': instance.goodsMismatchedRemark,
      'signatureFileName': instance.signatureFileName,
      'signature': instance.signature,
      'createDate': instance.createDate?.toIso8601String(),
    };
