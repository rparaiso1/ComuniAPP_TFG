import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String zoneId;
  final String? zoneName;
  final String? zoneType;
  final String userId;
  final String? userName;
  final String organizationId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? notes;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingEntity({
    required this.id,
    required this.zoneId,
    this.zoneName,
    this.zoneType,
    required this.userId,
    this.userName,
    required this.organizationId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    this.cancellationReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';

  @override
  List<Object?> get props => [
        id,
        zoneId,
        zoneName,
        zoneType,
        userId,
        userName,
        organizationId,
        startTime,
        endTime,
        status,
        notes,
        cancellationReason,
        cancelledAt,
        createdAt,
        updatedAt,
      ];
}
