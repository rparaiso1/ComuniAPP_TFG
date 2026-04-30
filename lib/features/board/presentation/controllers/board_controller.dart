import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/services/org_selector_service.dart';
import '../../data/datasources/board_remote_datasource.dart';
import '../../data/repositories/board_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/board_repository.dart';
import '../../../../core/utils/paginated_state.dart';

// Repository provider
final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authDataSource = ref.watch(authRemoteDataSourceProvider);
  
  final activeOrgId = ref.watch(activeOrgIdProvider);
  final remoteDataSource = BoardRemoteDataSourceImpl(
    client: httpClient,
    getToken: () => authDataSource.accessToken ?? '',
    getOrgId: () => activeOrgId,
  );

  return BoardRepositoryImpl(remoteDataSource: remoteDataSource);
});

// State class
class BoardState with PaginatedState {
  final List<PostEntity> posts;
  final bool isLoading;
  final String? error;
  final bool isCreating;
  @override
  final bool isLoadingMore;
  @override
  final bool hasMore;
  @override
  final int currentSkip;

  BoardState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.isCreating = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentSkip = 0,
  });

  BoardState copyWith({
    List<PostEntity>? posts,
    bool? isLoading,
    String? error,
    bool? isCreating,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentSkip,
  }) {
    return BoardState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCreating: isCreating ?? this.isCreating,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }
}

// Controller
class BoardController extends Notifier<BoardState> {
  late BoardRepository repository;

  @override
  BoardState build() {
    repository = ref.watch(boardRepositoryProvider);
    return BoardState();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null, currentSkip: 0, hasMore: true);
    try {
      final posts = await repository.getPosts('default', skip: 0, limit: kDefaultPageSize);
      state = state.copyWith(
        posts: posts,
        isLoading: false,
        currentSkip: posts.length,
        hasMore: posts.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final newPosts = await repository.getPosts(
        'default',
        skip: state.currentSkip,
        limit: kDefaultPageSize,
      );
      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoadingMore: false,
        currentSkip: state.currentSkip + newPosts.length,
        hasMore: newPosts.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      final newPost = await repository.createPost(
        title: title,
        content: content,
        communityId: 'default',
      );
      state = state.copyWith(
        posts: [newPost, ...state.posts],
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await repository.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Controller provider
final boardControllerProvider =
    NotifierProvider<BoardController, BoardState>(
  () => BoardController(),
);
