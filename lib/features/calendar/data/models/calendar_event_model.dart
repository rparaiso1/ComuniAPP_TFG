import '../../domain/entities/calendar_event_entity.dart';

class CalendarEventModel extends CalendarEventEntity {
  const CalendarEventModel({
    required super.id,
    required super.title,
    super.description,
    required super.start,
    required super.end,
    required super.type,
    required super.color,
    super.facilityName,
    super.userName,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      type: json['type'] ?? 'booking',
      color: json['color'] ?? '#2196F3',
      facilityName: json['facility_name'],
      userName: json['user_name'],
    );
  }
}
