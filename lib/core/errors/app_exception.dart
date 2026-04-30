class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

class AppAuthException extends AppException {
  AppAuthException({required super.message, super.code});
}

class NetworkException extends AppException {
  NetworkException({required super.message});
}

class CacheException extends AppException {
  CacheException({required super.message});
}

class ValidationException extends AppException {
  ValidationException({required super.message});
}

class NotFoundException extends AppException {
  NotFoundException({required super.message});
}

class ServerException extends AppException {
  ServerException({required super.message});
}

class UnauthorizedException extends AppException {
  UnauthorizedException({required super.message});
}

class ConflictException extends AppException {
  ConflictException({required super.message});
}

class ForbiddenException extends AppException {
  ForbiddenException({required super.message});
}
