import '../../domain/entities/incident_comment_entity.dart';

class IncidentCommentModel extends IncidentCommentEntity {
  const IncidentCommentModel({
    required super.id,
    required super.incidentId,
    required super.authorId,
    required super.authorName,
    required super.content,
    super.imageUrl,
    required super.createdAt,
  });

  factory IncidentCommentModel.fromJson(Map<String, dynamic> json) {
    return IncidentCommentModel(
      id: json['id']?.toString() ?? '',
      incidentId: json['incident_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      authorName: json['author_name'] ?? 'Usuario',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }
}
