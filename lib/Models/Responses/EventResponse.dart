import '../Event.dart';
import 'package:json_annotation/json_annotation.dart';

part 'EventResponse.g.dart';

@JsonSerializable()
class EventResponse {
  List<Event> iruimList;
  EventResponse(this.iruimList);

  factory EventResponse.fromJson(Map<String, dynamic> json) =>
      _$EventResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EventResponseToJson(this);
}
