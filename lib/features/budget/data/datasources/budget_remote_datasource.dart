import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<BudgetSummaryModel> getSummary({int? year});
  Future<List<BudgetEntryModel>> getEntries({
    int? year,
    String? entryType,
    String? category,
    int skip = 0,
    int limit = 50,
  });
  Future<Map<String, dynamic>> uploadCsv(List<int> fileBytes, String fileName);
  Future<void> deleteEntry(String entryId);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final http.Client client;
  final String Function() getToken;
  final String? Function()? getOrgId;

  BudgetRemoteDataSourceImpl({
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

  Map<String, String> get _authHeaders {
    final token = getToken();
    final orgId = getOrgId?.call();
    return {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (orgId != null && orgId.isNotEmpty) 'X-Organization-ID': orgId,
    };
  }

  @override
  Future<BudgetSummaryModel> getSummary({int? year}) async {
    try {
      final yearParam = year != null ? '?year=$year' : '';
      final response = await client.get(
        Uri.parse('$_baseUrl/api/budget/summary$yearParam'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return BudgetSummaryModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else {
        throw ServerException(message: 'Error al cargar el resumen presupuestario');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<List<BudgetEntryModel>> getEntries({
    int? year,
    String? entryType,
    String? category,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final params = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
        if (year != null) 'year': year.toString(),
        if (entryType != null) 'entry_type': entryType,
        if (category != null) 'category': category,
      };
      final uri = Uri.parse('$_baseUrl/api/budget').replace(queryParameters: params);
      final response = await client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => BudgetEntryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else {
        throw ServerException(message: 'Error al cargar partidas');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadCsv(List<int> fileBytes, String fileName) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/budget/upload'),
      );
      request.headers.addAll(_authHeaders);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      } else if (response.statusCode == 403) {
        throw UnauthorizedException(
            message: 'No tienes permisos para subir presupuesto');
      } else {
        final detail = (jsonDecode(response.body) as Map?)?['detail'] ?? 'Error al subir';
        throw ServerException(message: detail.toString());
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl/api/budget/$entryId'),
        headers: _headers,
      );
      if (response.statusCode == 204) return;
      if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      }
      if (response.statusCode == 404) {
        throw NotFoundException(message: 'Partida no encontrada');
      }
      throw ServerException(message: 'Error al eliminar la partida');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }
}
