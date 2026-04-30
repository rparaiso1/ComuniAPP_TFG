import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetUserProfileUsecase {
  final AuthRepository repository;

  GetUserProfileUsecase({required this.repository});

  Future<UserEntity> call(String userId) {
    return repository.getUserProfile(userId);
  }
}
