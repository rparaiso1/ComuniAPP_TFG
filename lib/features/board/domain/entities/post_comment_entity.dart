import 'package:equatable/equatable.dart';

class PostCommentEntity extends Equatable {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const PostCommentEntity({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, postId, authorId, authorName, content, createdAt];
}
