import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/incident_comment_model.dart';
import '../models/incident_model.dart';

abstract class IncidentRemoteDataSource {
  Future<List<IncidentModel>> getIncidents({int skip = 0, int limit = 100, String? statusFilter, String? priorityFilter, bool myOnly = false});
  Future<IncidentModel> getIncident(String incidentId);
  Future<IncidentModel> createIncident({
    required String title,
    required String description,
    required String priority,
    String? location,
  });
  Future<IncidentModel> updateIncidentStatus({
    required String incidentId,
    required String status,
  });
  Future<void> deleteIncident(String incidentId);
  Future<IncidentCommentModel> addComment(String incidentId, {required String content});
  Future<List<IncidentCommentModel>> getComments(String incidentId);
}

class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final http.Client client;
  final String Function() getToken;
  final String? Function()? getOrgId;

  IncidentRemoteDataSourceImpl({
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
  Future<List<IncidentModel>> getIncidents({int skip = 0, int limit = 100, String? statusFilter, String? priorityFilter, bool myOnly = false}) async {
    try {
      final params = <String, String>{
        'skip': '$skip',
        'limit': '$limit',
      };
      if (statusFilter != null) params['status_filter'] = statusFilter;
      if (priorityFilter != null) params['priority_filter'] = priorityFilter;
      if (myOnly) params['my_only'] = 'true';
      final uri = Uri.parse('$_baseUrl/api/incidents').replace(queryParameters: params);
      final response = await client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => IncidentModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else {
        throw ServerException(message: 'Failed to load incidents');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<IncidentModel> getIncident(String incidentId) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/incidents/$incidentId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return IncidentModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Incident not found');
      } else {
        throw ServerException(message: 'Failed to load incident');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<IncidentModel> createIncident({
    required String title,
    required String description,
    required String priority,
    String? location,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/incidents'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'priority': priority,
          'location': location,
        }),
      );

      if (response.statusCode == 201) {
        return IncidentModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(message: 'Failed to create incident');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<IncidentModel> updateIncidentStatus({
    required String incidentId,
    required String status,
  }) async {
    try {
      final response = await client.put(
        Uri.parse('$_baseUrl/api/incidents/$incidentId'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return IncidentModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(message: 'Failed to update incident');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteIncident(String incidentId) async {
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl/api/incidents/$incidentId'),
        headers: _headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw UnauthorizedException(message: 'No permission to delete');
        }
        throw ServerException(message: 'Failed to delete incident');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<IncidentCommentModel> addComment(String incidentId, {required String content}) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/incidents/$incidentId/comments'),
        headers: _headers,
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 201) {
        return IncidentCommentModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw ValidationException(message: 'Cannot comment on this incident');
      } else {
        throw ServerException(message: 'Failed to add comment');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<IncidentCommentModel>> getComments(String incidentId) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/incidents/$incidentId/comments'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => IncidentCommentModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to load comments');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }
}
