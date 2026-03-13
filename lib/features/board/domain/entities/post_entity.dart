import 'package:equatable/equatable.dart';
import 'post_comment_entity.dart';

class PostEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String communityId;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final bool userHasLiked;
  final List<PostCommentEntity> comments;

  const PostEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.communityId,
    required this.attachmentUrls,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.commentCount,
    this.userHasLiked = false,
    this.comments = const [],
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    authorId,
    authorName,
    communityId,
    attachmentUrls,
    createdAt,
    updatedAt,
    likeCount,
    commentCount,
    userHasLiked,
    comments,
  ];
}
