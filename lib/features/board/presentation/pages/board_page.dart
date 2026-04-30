import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/post_entity.dart';
import '../controllers/board_controller.dart';

class BoardPage extends ConsumerStatefulWidget {
  const BoardPage({super.key});

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends ConsumerState<BoardPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(boardControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _loadPosts() async {
    await ref.read(boardControllerProvider.notifier).loadPosts();
  }

  @override
  Widget build(BuildContext context, ) {
    final state = ref.watch(boardControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final canManage = authState.user?.role.isAdminOrPresident ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.colors.backgroundGradient,
        ),
        child: SafeArea(
          child: ContentConstraint(
            child: RefreshIndicator(
              onRefresh: _loadPosts,
              child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header
                SliverAppBar(
                  expandedHeight: 140,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: context.colors.onGradient),
                      tooltip: context.l.goBack,
                      onPressed: () => context.canPop() ? context.pop() : context.goNamed('home'),
                    ),
                  ),
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          context.l.boardTitle,
                          style: TextStyle(
                            color: context.colors.onGradient,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                if (state.isLoading && state.posts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null && state.posts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline_rounded, size: 64, color: context.colors.textTertiary),
                            const SizedBox(height: 16),
                            Text(
                              ErrorDialog.getFriendlyMessage(context, state.error!),
                              style: TextStyle(color: context.colors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _loadPosts,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(context.l.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (state.posts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.dashboard_outlined,
                              size: 64,
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            context.l.noPosts,
                            style: TextStyle(
                              fontSize: 18,
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l.postsWillAppear,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = state.posts[index];
                          return StaggeredListItem(
                            index: index,
                            child: _PostCard(
                              post: post,
                              canDelete: canManage,
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(context.l.deletePost),
                                    content: Text(context.l.deletePostConfirm),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: Text(context.l.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: context.colors.onGradient,
                                        ),
                                        child: Text(context.l.delete),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(boardControllerProvider.notifier).deletePost(post.id);
                                }
                              },
                              onTap: () => context.goNamed('boardDetail', pathParameters: {'postId': post.id}),
                            ),
                          );
                        },
                        childCount: state.posts.length,
                      ),
                    ),
                  ),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: context.colors.onGradient),
        label: Text(context.l.publish, style: TextStyle(color: context.colors.onGradient)),
      ),
    );
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l.newPost),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: context.l.title,
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: context.l.content,
                  prefixIcon: const Icon(Icons.text_fields),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l.completeTitleContent)),
                );
                return;
              }
              Navigator.pop(context);
              await ref.read(boardControllerProvider.notifier).createPost(
                    title: titleController.text,
                    content: contentController.text,
                  );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: context.colors.onGradient,
              backgroundColor: AppColors.primary,
            ),
            child: Text(context.l.publish),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostEntity post;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.canDelete,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        post.authorName.isNotEmpty
                            ? post.authorName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: context.colors.onGradient,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            timeago.format(post.createdAt, locale: 'es'),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canDelete)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: context.colors.error, size: 20),
                        tooltip: context.l.deletePost,
                        onPressed: onDelete,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 18, color: context.colors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likeCount}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.chat_bubble_outline, size: 18, color: context.colors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
