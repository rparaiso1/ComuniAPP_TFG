import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.authorName,
    required super.communityId,
    required super.attachmentUrls,
    required super.createdAt,
    required super.updatedAt,
    required super.likeCount,
    required super.commentCount,
    super.userHasLiked = false,
    super.comments = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final commentsList = (json['comments'] as List<dynamic>? ?? [])
        .map((c) => PostCommentEntity(
              id: c['id'] ?? '',
              postId: c['post_id'] ?? '',
              authorId: c['author_id'] ?? '',
              authorName: c['author_name'] ?? '',
              content: c['content'] ?? '',
              createdAt: DateTime.parse(
                  c['created_at'] ?? DateTime.now().toIso8601String()),
            ))
        .toList();

    return PostModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'] ?? '',
      communityId: json['organization_id'] ?? '',
      attachmentUrls: [],
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      userHasLiked: json['user_has_liked'] ?? false,
      comments: commentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_id': authorId,
      'is_pinned': false,
    };
  }
}
