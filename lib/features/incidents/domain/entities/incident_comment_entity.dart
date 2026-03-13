import 'package:equatable/equatable.dart';

class IncidentCommentEntity extends Equatable {
  final String id;
  final String incidentId;
  final String authorId;
  final String authorName;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  const IncidentCommentEntity({
    required this.id,
    required this.incidentId,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, incidentId, authorId, authorName, content, imageUrl, createdAt];
}
