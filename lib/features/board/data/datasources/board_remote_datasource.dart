import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/post_model.dart';

abstract class BoardRemoteDataSource {
  Future<List<PostModel>> getPosts({int skip = 0, int limit = 50});
  Future<PostModel> getPost(String postId);
  Future<PostModel> createPost({
    required String title,
    required String content,
    bool isPinned = false,
  });
  Future<PostModel> updatePost({
    required String postId,
    String? title,
    String? content,
    bool? isPinned,
  });
  Future<void> deletePost(String postId);
  Future<Map<String, dynamic>> addComment(String postId, String content);
  Future<void> deleteComment(String commentId);
  Future<bool> toggleLike(String postId);
}

class BoardRemoteDataSourceImpl implements BoardRemoteDataSource {
  final http.Client client;
  final String Function() getToken;
  final String? Function()? getOrgId;

  BoardRemoteDataSourceImpl({
    required this.client,
    required this.getToken,
    this.getOrgId,
  });

  String get _baseUrl => EnvConfig.apiBaseUrl;

  Map<String, String> get _headers {
    final token = getToken();
    final orgId = getOrgId?.call();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (orgId != null && orgId.isNotEmpty) 'X-Organization-ID': orgId,
    };
  }

  @override
  Future<List<PostModel>> getPosts({int skip = 0, int limit = 50}) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/posts?skip=$skip&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else {
        throw ServerException(message: 'Failed to load posts');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> getPost(String postId) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/posts/$postId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Post not found');
      } else {
        throw ServerException(message: 'Failed to load post');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> createPost({
    required String title,
    required String content,
    bool isPinned = false,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/posts'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'content': content,
          'is_pinned': isPinned,
        }),
      );

      if (response.statusCode == 201) {
        return PostModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(message: 'Failed to create post');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> updatePost({
    required String postId,
    String? title,
    String? content,
    bool? isPinned,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (content != null) body['content'] = content;
      if (isPinned != null) body['is_pinned'] = isPinned;

      final response = await client.put(
        Uri.parse('$_baseUrl/api/posts/$postId'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw UnauthorizedException(message: 'No permission to update');
      } else {
        throw ServerException(message: 'Failed to update post');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl/api/posts/$postId'),
        headers: _headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw UnauthorizedException(message: 'No permission to delete');
        }
        throw ServerException(message: 'Failed to delete post');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> addComment(String postId, String content) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/posts/$postId/comments'),
        headers: _headers,
        body: jsonEncode({'content': content}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else {
        final detail = _extractDetail(response.body);
        throw ServerException(message: detail ?? 'Failed to add comment (${response.statusCode})');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl/api/posts/comments/$commentId'),
        headers: _headers,
      );
      if (response.statusCode != 204 && response.statusCode != 200) {
        final detail = _extractDetail(response.body);
        throw ServerException(message: detail ?? 'Failed to delete comment (${response.statusCode})');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> toggleLike(String postId) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/posts/$postId/like'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['liked'] as bool;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else {
        final detail = _extractDetail(response.body);
        throw ServerException(message: detail ?? 'Failed to toggle like (${response.statusCode})');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  /// Extract 'detail' field from a FastAPI error response body.
  String? _extractDetail(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic> && json.containsKey('detail')) {
        return json['detail'].toString();
      }
    } catch (_) {}
    return null;
  }
}
