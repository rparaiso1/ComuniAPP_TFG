import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Get currently authenticated user
  Future<UserEntity?> getCurrentUser();

  /// Login with email and password
  Future<UserEntity> login(String email, String password);

  /// Logout current user
  Future<void> logout();

  /// Get user profile with extended data
  Future<UserEntity> getUserProfile(String userId);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get user session token
  Future<String?> getSessionToken();
}
