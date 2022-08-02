import 'package:json_annotation/json_annotation.dart';
part 'Event.g.dart';

@JsonSerializable()
class Event {
  int iruaCode; //eventID
  String sugIruaName; //eventType
  String iruaTeur; //eventDesc
  DateTime iruaPtichaDate; //startDate
  DateTime iruaSgiraDate;

  Event(this.iruaCode, this.sugIruaName, this.iruaTeur, this.iruaPtichaDate,
      this.iruaSgiraDate); //endDate

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);


}
