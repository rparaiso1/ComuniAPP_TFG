import 'package:equatable/equatable.dart';

import 'incident_comment_entity.dart';

class IncidentEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String? location;
  final String userId;
  final String userName;
  final String? assignedToId;
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<IncidentCommentEntity> comments;

  const IncidentEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.location,
    required this.userId,
    required this.userName,
    this.assignedToId,
    this.assignedToName,
    required this.createdAt,
    this.updatedAt,
    this.comments = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        status,
        location,
        userId,
        userName,
        assignedToId,
        assignedToName,
        createdAt,
        updatedAt,
        comments,
      ];
}
