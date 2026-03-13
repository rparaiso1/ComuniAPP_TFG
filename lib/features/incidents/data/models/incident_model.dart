import '../../domain/entities/incident_entity.dart';
import 'incident_comment_model.dart';

class IncidentModel extends IncidentEntity {
  const IncidentModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priority,
    required super.status,
    super.location,
    required super.userId,
    required super.userName,
    super.assignedToId,
    super.assignedToName,
    required super.createdAt,
    super.updatedAt,
    super.comments = const [],
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'low',
      status: json['status'] ?? 'open',
      location: json['location'],
      userId: json['reporter_id'] ?? json['user_id'] ?? '',
      userName: json['reporter_name'] ?? json['user']?['full_name'] ?? 'Usuario',
      assignedToId: json['assigned_to_id'],
      assignedToName: json['assigned_to_name'] ?? json['assigned_to']?['full_name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => IncidentCommentModel.fromJson(c as Map<String, dynamic>))
          .toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': super.title,
      'description': super.description,
      'priority': super.priority,
      'status': super.status,
      'location': super.location,
      'assigned_to_id': super.assignedToId,
    };
  }
}
