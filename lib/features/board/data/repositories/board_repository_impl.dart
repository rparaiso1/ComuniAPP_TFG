import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/board_repository.dart';
import '../datasources/board_remote_datasource.dart';

class BoardRepositoryImpl implements BoardRepository {
  final BoardRemoteDataSource remoteDataSource;

  BoardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> getPosts(String communityId, {int skip = 0, int limit = 20}) async {
    return await remoteDataSource.getPosts(skip: skip, limit: limit);
  }

  @override
  Future<PostEntity> getPostDetail(String postId) async {
    return await remoteDataSource.getPost(postId);
  }

  @override
  Future<PostEntity> createPost({
    required String title,
    required String content,
    required String communityId,
    List<String>? attachmentUrls,
  }) async {
    return await remoteDataSource.createPost(
      title: title,
      content: content,
      isPinned: false,
    );
  }

  @override
  Future<void> deletePost(String postId) async {
    await remoteDataSource.deletePost(postId);
  }

  @override
  Future<Map<String, dynamic>> addComment(String postId, String content) async {
    return await remoteDataSource.addComment(postId, content);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await remoteDataSource.deleteComment(commentId);
  }

  @override
  Future<bool> toggleLike(String postId) async {
    return await remoteDataSource.toggleLike(postId);
  }
}
