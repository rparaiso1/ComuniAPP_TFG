import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSourceImpl remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    await localDataSource.saveUser(user);
    // Save tokens to localStorage for persistence
    if (remoteDataSource.accessToken != null) {
      await localDataSource.saveSessionToken(remoteDataSource.accessToken!);
    }
    if (remoteDataSource.refreshTokenValue != null) {
      await localDataSource.saveRefreshToken(remoteDataSource.refreshTokenValue!);
    }
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Remote logout failure should not prevent local cleanup
    } finally {
      await localDataSource.deleteUser();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // First, restore token from localStorage if not set
      if (remoteDataSource.accessToken == null) {
        final savedToken = await localDataSource.getSessionToken();
        if (savedToken != null) {
          remoteDataSource.setAccessToken(savedToken);
        }
      }

      // Try to get from remote
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.saveUser(remoteUser);
        return remoteUser;
      }

      // Fallback to local cache
      return await localDataSource.getUser();
    } catch (e) {
      return await localDataSource.getUser();
    }
  }

  @override
  Future<UserEntity> getUserProfile(String userId) async {
    final user = await remoteDataSource.getUserProfile(userId);
    await localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getSessionToken() async {
    try {
      return await localDataSource.getSessionToken();
    } catch (e) {
      return null;
    }
  }
}
