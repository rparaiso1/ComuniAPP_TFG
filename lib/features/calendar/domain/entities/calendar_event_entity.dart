import 'package:equatable/equatable.dart';

class CalendarEventEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final String type;
  final String color;
  final String? facilityName;
  final String? userName;

  const CalendarEventEntity({
    required this.id,
    required this.title,
    this.description,
    required this.start,
    required this.end,
    required this.type,
    required this.color,
    this.facilityName,
    this.userName,
  });

  /// Convierte color hex a Color de Flutter
  int get colorValue {
    String hex = color.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        start,
        end,
        type,
        color,
        facilityName,
        userName,
      ];
}
