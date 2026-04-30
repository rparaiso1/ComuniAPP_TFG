import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getBookings({
    String? zoneId,
    bool myOnly,
    int skip,
    int limit,
  });
  Future<BookingModel> getBooking(String bookingId);
  Future<BookingModel> createBooking({
    required String zoneId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });
  Future<BookingModel> cancelBooking(String bookingId, {String? reason});
  Future<BookingModel> approveBooking(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final http.Client client;
  final String Function() getToken;
  final String? Function()? getOrgId;

  BookingRemoteDataSourceImpl({
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
  Future<List<BookingModel>> getBookings({
    String? zoneId,
    bool myOnly = false,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final params = <String, String>{
        'skip': '$skip',
        'limit': '$limit',
      };
      if (zoneId != null) params['zone_id'] = zoneId;
      if (myOnly) params['my_only'] = 'true';

      final uri = Uri.parse('$_baseUrl/api/bookings')
          .replace(queryParameters: params);

      final response = await client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesión expirada');
      } else {
        throw ServerException(message: 'Error al cargar reservas');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> getBooking(String bookingId) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/bookings/$bookingId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Reserva no encontrada');
      } else {
        throw ServerException(message: 'Error al cargar reserva');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> createBooking({
    required String zoneId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'zone_id': zoneId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      };
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;

      final response = await client.post(
        Uri.parse('$_baseUrl/api/bookings'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return BookingModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 409) {
        throw ConflictException(message: 'Ya existe una reserva en ese horario');
      } else {
        final detail = _extractDetail(response.body);
        throw ServerException(message: detail ?? 'Error al crear reserva');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) body['reason'] = reason;

      final response = await client.post(
        Uri.parse('$_baseUrl/api/bookings/$bookingId/cancel'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Reserva no encontrada');
      } else {
        throw ServerException(message: 'Error al cancelar reserva');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  String? _extractDetail(String body) {
    try {
      final json = jsonDecode(body);
      return json['detail'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BookingModel> approveBooking(String bookingId) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/bookings/$bookingId/approve'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw UnauthorizedException(message: 'No permission to approve bookings');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Reserva no encontrada');
      } else {
        final detail = _extractDetail(response.body);
        throw ServerException(message: detail ?? 'Error al aprobar reserva');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }
}
