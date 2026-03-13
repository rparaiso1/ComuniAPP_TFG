import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localStorage = ref.watch(localStorageProvider);

  final localDataSource = AuthLocalDataSourceImpl(
    localStorage: localStorage,
  );

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Usecases
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUsecase(repository: repository);
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUsecase(repository: repository);
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUsecase(repository: repository);
});

// Auth state
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth controller
class AuthController extends Notifier<AuthState> {
  late LoginUsecase _loginUsecase;
  late LogoutUsecase _logoutUsecase;
  late GetCurrentUserUsecase _getCurrentUserUsecase;

  @override
  AuthState build() {
    _loginUsecase = ref.watch(loginUsecaseProvider);
    _logoutUsecase = ref.watch(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.watch(getCurrentUserUsecaseProvider);
    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _loginUsecase(email, password);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _logoutUsecase();
    state = const AuthState();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _getCurrentUserUsecase();
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );

    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

// AuthController provider
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(
  () => AuthController(),
);
