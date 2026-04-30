import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/document_model.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentModel>> getDocuments({int skip = 0, int limit = 100, String? category});
  Future<DocumentModel> getDocument(String documentId);
  Future<DocumentModel> uploadDocument({
    required String title,
    required String fileUrl,
    required String fileType,
    int? fileSize,
    String? description,
    String? category,
  });
  Future<DocumentModel> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String title,
    String? description,
    String? category,
  });
  Future<void> deleteDocument(String documentId);
  Future<DocumentModel> approveDocument(String documentId, {required bool approved, String? rejectionReason});
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final http.Client client;
  final String Function() getToken;
  final String? Function()? getOrgId;

  DocumentRemoteDataSourceImpl({
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
  Future<List<DocumentModel>> getDocuments({int skip = 0, int limit = 100, String? category}) async {
    try {
      final queryParams = 'skip=$skip&limit=$limit${category != null ? '&category=$category' : ''}';
      final response = await client.get(
        Uri.parse('$_baseUrl/api/documents?$queryParams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DocumentModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else {
        throw ServerException(message: 'Failed to load documents');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<DocumentModel> getDocument(String documentId) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/documents/$documentId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return DocumentModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Document not found');
      } else {
        throw ServerException(message: 'Failed to load document');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
    required String title,
    required String fileUrl,
    required String fileType,
    int? fileSize,
    String? description,
    String? category,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/documents'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'file_url': fileUrl,
          'file_type': fileType,
          'file_size': fileSize,
          'description': description,
          'category': category,
        }),
      );

      if (response.statusCode == 201) {
        return DocumentModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(message: 'Failed to upload document');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl/api/documents/$documentId'),
        headers: _headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw UnauthorizedException(message: 'No permission to delete');
        }
        throw ServerException(message: 'Failed to delete document');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<DocumentModel> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String title,
    String? description,
    String? category,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/documents/upload');
      final request = http.MultipartRequest('POST', uri);

      // Auth header (no Content-Type — multipart sets its own)
      final token = getToken();
      request.headers['Authorization'] = 'Bearer $token';

      // File field
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

      // Form fields
      request.fields['title'] = title;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      if (category != null && category.isNotEmpty) {
        request.fields['category'] = category;
      }

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();

      if (streamed.statusCode == 201) {
        return DocumentModel.fromJson(jsonDecode(responseBody));
      } else if (streamed.statusCode == 400) {
        final body = jsonDecode(responseBody);
        throw ServerException(message: body['detail'] ?? 'Bad request');
      } else if (streamed.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else if (streamed.statusCode == 403) {
        throw UnauthorizedException(message: 'No permission to upload');
      } else {
        throw ServerException(message: 'Failed to upload file');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<DocumentModel> approveDocument(String documentId, {required bool approved, String? rejectionReason}) async {
    try {
      final body = <String, dynamic>{
        'approved': approved,
      };
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        body['rejection_reason'] = rejectionReason;
      }

      final response = await client.post(
        Uri.parse('$_baseUrl/api/documents/$documentId/approve'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return DocumentModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw UnauthorizedException(message: 'No permission to approve documents');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Document not found');
      } else {
        throw ServerException(message: 'Failed to approve document');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }
}
