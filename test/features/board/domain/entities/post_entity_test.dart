import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/board/domain/entities/post_entity.dart';
import 'package:comuniapp/features/board/domain/entities/post_comment_entity.dart';

void main() {
  final baseDate = DateTime(2026, 4, 5, 12, 0);

  PostEntity createPost({
    String id = 'post-1',
    String title = 'Reunión de vecinos',
    String content = 'Se convoca la reunión ordinaria',
    String authorId = 'user-1',
    String authorName = 'Admin User',
    String communityId = 'org-1',
    List<String> attachmentUrls = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    int likeCount = 0,
    int commentCount = 0,
    bool userHasLiked = false,
    List<PostCommentEntity> comments = const [],
  }) {
    return PostEntity(
      id: id,
      title: title,
      content: content,
      authorId: authorId,
      authorName: authorName,
      communityId: communityId,
      attachmentUrls: attachmentUrls,
      createdAt: createdAt ?? baseDate,
      updatedAt: updatedAt ?? baseDate,
      likeCount: likeCount,
      commentCount: commentCount,
      userHasLiked: userHasLiked,
      comments: comments,
    );
  }

  group('PostEntity constructor', () {
    test('creates instance with all required fields', () {
      final post = createPost();
      expect(post.id, 'post-1');
      expect(post.title, 'Reunión de vecinos');
      expect(post.content, 'Se convoca la reunión ordinaria');
      expect(post.authorId, 'user-1');
      expect(post.authorName, 'Admin User');
      expect(post.communityId, 'org-1');
      expect(post.attachmentUrls, isEmpty);
      expect(post.createdAt, baseDate);
      expect(post.updatedAt, baseDate);
    });

    test('defaults userHasLiked to false and comments to empty', () {
      final post = createPost();
      expect(post.userHasLiked, isFalse);
      expect(post.comments, isEmpty);
      expect(post.likeCount, 0);
      expect(post.commentCount, 0);
    });

    test('stores interaction data when provided', () {
      final post = createPost(
        likeCount: 5,
        commentCount: 3,
        userHasLiked: true,
      );
      expect(post.likeCount, 5);
      expect(post.commentCount, 3);
      expect(post.userHasLiked, isTrue);
    });

    test('stores comments list', () {
      final comment = PostCommentEntity(
        id: 'comment-1',
        postId: 'post-1',
        authorId: 'user-2',
        authorName: 'Vecino',
        content: 'De acuerdo',
        createdAt: baseDate,
      );
      final post = createPost(comments: [comment]);
      expect(post.comments, hasLength(1));
      expect(post.comments.first.content, 'De acuerdo');
    });
  });

  group('PostCommentEntity', () {
    test('creates instance with all fields', () {
      final comment = PostCommentEntity(
        id: 'comment-1',
        postId: 'post-1',
        authorId: 'user-2',
        authorName: 'María López',
        content: 'Buen punto',
        createdAt: baseDate,
      );
      expect(comment.id, 'comment-1');
      expect(comment.postId, 'post-1');
      expect(comment.authorId, 'user-2');
      expect(comment.authorName, 'María López');
      expect(comment.content, 'Buen punto');
      expect(comment.createdAt, baseDate);
    });

    test('two comments with same props are equal', () {
      final c1 = PostCommentEntity(
        id: 'c1', postId: 'p1', authorId: 'u1',
        authorName: 'Test', content: 'Hi', createdAt: baseDate,
      );
      final c2 = PostCommentEntity(
        id: 'c1', postId: 'p1', authorId: 'u1',
        authorName: 'Test', content: 'Hi', createdAt: baseDate,
      );
      expect(c1, equals(c2));
    });

    test('two comments with different id are not equal', () {
      final c1 = PostCommentEntity(
        id: 'c1', postId: 'p1', authorId: 'u1',
        authorName: 'Test', content: 'Hi', createdAt: baseDate,
      );
      final c2 = PostCommentEntity(
        id: 'c2', postId: 'p1', authorId: 'u1',
        authorName: 'Test', content: 'Hi', createdAt: baseDate,
      );
      expect(c1, isNot(equals(c2)));
    });
  });

  group('PostEntity Equatable', () {
    test('two entities with same props are equal', () {
      final p1 = createPost();
      final p2 = createPost();
      expect(p1, equals(p2));
    });

    test('two entities with different id are not equal', () {
      final p1 = createPost(id: 'post-1');
      final p2 = createPost(id: 'post-2');
      expect(p1, isNot(equals(p2)));
    });

    test('entities with different likeCount are not equal', () {
      final p1 = createPost(likeCount: 0);
      final p2 = createPost(likeCount: 5);
      expect(p1, isNot(equals(p2)));
    });

    test('entities with different userHasLiked are not equal', () {
      final p1 = createPost(userHasLiked: false);
      final p2 = createPost(userHasLiked: true);
      expect(p1, isNot(equals(p2)));
    });
  });
}
