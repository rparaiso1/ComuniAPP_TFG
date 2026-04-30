import '../entities/post_entity.dart';

abstract class BoardRepository {
  Future<List<PostEntity>> getPosts(String communityId, {int skip = 0, int limit = 20});
  Future<PostEntity> getPostDetail(String postId);
  Future<PostEntity> createPost({
    required String title,
    required String content,
    required String communityId,
    List<String>? attachmentUrls,
  });
  Future<void> deletePost(String postId);
  Future<Map<String, dynamic>> addComment(String postId, String content);
  Future<void> deleteComment(String commentId);
  Future<bool> toggleLike(String postId);
}
