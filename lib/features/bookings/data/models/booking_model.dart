import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.zoneId,
    super.zoneName,
    super.zoneType,
    required super.userId,
    super.userName,
    required super.organizationId,
    required super.startTime,
    required super.endTime,
    required super.status,
    super.notes,
    super.cancellationReason,
    super.cancelledAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      zoneId: json['zone_id'] ?? '',
      zoneName: json['zone_name'],
      zoneType: json['zone_type'],
      userId: json['user_id'] ?? '',
      userName: json['user_name'],
      organizationId: json['organization_id'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status'] ?? 'confirmed',
      notes: json['notes'],
      cancellationReason: json['cancellation_reason'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone_id': zoneId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }
}
