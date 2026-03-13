import '../../../../core/services/local_storage_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
  Future<void> saveSessionToken(String token);
  Future<String?> getSessionToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorageService localStorage;

  static const String _userKey = 'current_user';
  static const String _sessionTokenKey = 'session_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthLocalDataSourceImpl({required this.localStorage});

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await localStorage.saveUserData(_userKey, user.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to save user');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userData = localStorage.getUserData(_userKey);
      if (userData == null) {
        return null;
      }
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await localStorage.deleteUserData(_userKey);
      await localStorage.deleteUserData(_sessionTokenKey);
      await localStorage.deleteUserData(_refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to delete user');
    }
  }

  @override
  Future<void> saveSessionToken(String token) async {
    try {
      await localStorage.saveUserData(_sessionTokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Failed to save session token');
    }
  }

  @override
  Future<String?> getSessionToken() async {
    try {
      return localStorage.getUserData(_sessionTokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await localStorage.saveUserData(_refreshTokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Failed to save refresh token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return localStorage.getUserData(_refreshTokenKey);
    } catch (e) {
      return null;
    }
  }
}
