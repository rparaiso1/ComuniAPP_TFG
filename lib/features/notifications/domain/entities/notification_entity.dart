import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show IconData, Icons;

class NotificationEntity extends Equatable {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? link;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.link,
    this.data,
  });

  IconData get icon {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'incident':
        return Icons.report_problem;
      case 'poll':
        return Icons.poll;
      case 'document':
        return Icons.description;
      case 'payment':
        return Icons.payment;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        isRead,
        createdAt,
        link,
        data,
      ];
}
