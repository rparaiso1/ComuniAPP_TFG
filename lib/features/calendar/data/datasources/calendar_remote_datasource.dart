import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/calendar_event_model.dart';

abstract class CalendarRemoteDataSource {
  Future<List<CalendarEventModel>> getMonthEvents(int year, int month);
  Future<List<CalendarEventModel>> getTodayEvents();
  Future<List<CalendarEventModel>> getUpcomingEvents();
  Future<List<CalendarEventModel>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  final http.Client client;
  final String Function() getToken;
  final String? Function()? getOrgId;

  CalendarRemoteDataSourceImpl({
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

  List<CalendarEventModel> _parseEventList(String body) {
    final List<dynamic> data = jsonDecode(body);
    return data.map((json) => CalendarEventModel.fromJson(json)).toList();
  }

  @override
  Future<List<CalendarEventModel>> getMonthEvents(int year, int month) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/calendar/month/$year/$month'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> events = data['events'] ?? [];
        return events.map((json) => CalendarEventModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesión expirada');
      } else {
        throw ServerException(message: 'Error al cargar eventos del mes');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<List<CalendarEventModel>> getTodayEvents() async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/calendar/today'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _parseEventList(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesión expirada');
      } else {
        throw ServerException(message: 'Error al cargar eventos de hoy');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<List<CalendarEventModel>> getUpcomingEvents() async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/calendar/upcoming'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _parseEventList(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesión expirada');
      } else {
        throw ServerException(message: 'Error al cargar próximos eventos');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<List<CalendarEventModel>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/calendar/events').replace(
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      final response = await client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return _parseEventList(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesión expirada');
      } else {
        throw ServerException(message: 'Error al cargar eventos');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }
}
