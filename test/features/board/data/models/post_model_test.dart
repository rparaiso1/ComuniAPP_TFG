import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/board/data/models/post_model.dart';
import 'package:comuniapp/features/board/domain/entities/post_entity.dart';

void main() {
  final validJson = {
    'id': 'post-1',
    'title': 'Aviso corte de agua',
    'content': 'Se cortará el agua el próximo martes de 10 a 14h',
    'author_id': 'user-1',
    'author_name': 'Admin User',
    'organization_id': 'org-1',
    'created_at': '2026-04-05T12:00:00.000',
    'updated_at': '2026-04-05T13:00:00.000',
    'like_count': 3,
    'comment_count': 2,
    'user_has_liked': true,
    'comments': [
      {
        'id': 'comment-1',
        'post_id': 'post-1',
        'author_id': 'user-2',
        'author_name': 'Vecino Juan',
        'content': 'Gracias por avisar',
        'created_at': '2026-04-05T14:00:00.000',
      },
      {
        'id': 'comment-2',
        'post_id': 'post-1',
        'author_id': 'user-3',
        'author_name': 'Vecina Ana',
        'content': '¿A qué hora exactamente?',
        'created_at': '2026-04-05T15:00:00.000',
      },
    ],
  };

  group('PostModel', () {
    test('is a subclass of PostEntity', () {
      final model = PostModel.fromJson(validJson);
      expect(model, isA<PostEntity>());
    });
  });

  group('PostModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = PostModel.fromJson(validJson);
      expect(model.id, 'post-1');
      expect(model.title, 'Aviso corte de agua');
      expect(model.content,
          'Se cortará el agua el próximo martes de 10 a 14h');
      expect(model.authorId, 'user-1');
      expect(model.authorName, 'Admin User');
      expect(model.communityId, 'org-1');
      expect(model.createdAt, DateTime(2026, 4, 5, 12, 0));
      expect(model.updatedAt, DateTime(2026, 4, 5, 13, 0));
      expect(model.likeCount, 3);
      expect(model.commentCount, 2);
      expect(model.userHasLiked, isTrue);
    });

    test('parses comments list correctly', () {
      final model = PostModel.fromJson(validJson);
      expect(model.comments, hasLength(2));
      expect(model.comments[0].id, 'comment-1');
      expect(model.comments[0].authorName, 'Vecino Juan');
      expect(model.comments[0].content, 'Gracias por avisar');
      expect(model.comments[1].id, 'comment-2');
      expect(model.comments[1].authorName, 'Vecina Ana');
    });

    test('handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'post-2',
        'title': 'Test post',
        'content': 'Contenido',
        'author_id': 'user-1',
        'author_name': 'Test',
        'organization_id': 'org-1',
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
      };
      final model = PostModel.fromJson(minimalJson);
      expect(model.likeCount, 0);
      expect(model.commentCount, 0);
      expect(model.userHasLiked, isFalse);
      expect(model.comments, isEmpty);
      expect(model.attachmentUrls, isEmpty);
    });

    test('defaults id, title, content, authorId, authorName, communityId to empty string', () {
      final json = <String, dynamic>{
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
      };
      final model = PostModel.fromJson(json);
      expect(model.id, '');
      expect(model.title, '');
      expect(model.content, '');
      expect(model.authorId, '');
      expect(model.authorName, '');
      expect(model.communityId, '');
    });

    test('handles null comments list', () {
      final json = {
        ...validJson,
        'comments': null,
      };
      final model = PostModel.fromJson(json);
      expect(model.comments, isEmpty);
    });

    test('attachmentUrls is always empty list', () {
      final model = PostModel.fromJson(validJson);
      expect(model.attachmentUrls, isEmpty);
    });
  });

  group('PostModel.toJson', () {
    test('produces correct JSON map', () {
      final model = PostModel.fromJson(validJson);
      final json = model.toJson();
      expect(json['id'], 'post-1');
      expect(json['title'], 'Aviso corte de agua');
      expect(json['content'],
          'Se cortará el agua el próximo martes de 10 a 14h');
      expect(json['author_id'], 'user-1');
      expect(json['is_pinned'], isFalse);
    });

    test('does not include timestamps, likes, or comments', () {
      final model = PostModel.fromJson(validJson);
      final json = model.toJson();
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
      expect(json.containsKey('like_count'), isFalse);
      expect(json.containsKey('comment_count'), isFalse);
      expect(json.containsKey('comments'), isFalse);
      expect(json.containsKey('user_has_liked'), isFalse);
    });
  });
}
