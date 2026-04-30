import '../entities/post_entity.dart';
import '../repositories/board_repository.dart';

class GetPostsUsecase {
  final BoardRepository repository;

  GetPostsUsecase({required this.repository});

  Future<List<PostEntity>> call(String communityId, {int skip = 0, int limit = 20}) {
    return repository.getPosts(communityId, skip: skip, limit: limit);
  }
}
