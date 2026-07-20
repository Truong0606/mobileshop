/// Custom exception classes for API error handling.
///
/// Provides a structured hierarchy of exceptions for different
/// HTTP error scenarios encountered during API communication.
library;

/// Base exception for all API-related errors.
class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown when a network connectivity issue occurs (no internet, timeout, etc.).
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
    super.statusCode,
  });

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

/// Thrown when the server returns a 5xx error.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Lỗi máy chủ. Vui lòng thử lại sau.',
    super.statusCode,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when a 401 Unauthorized response is received.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    super.statusCode = 401,
  });

  @override
  String toString() => 'UnauthorizedException($statusCode): $message';
}

/// Thrown when a 404 Not Found response is received.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Không tìm thấy tài nguyên yêu cầu.',
    super.statusCode = 404,
  });

  @override
  String toString() => 'NotFoundException($statusCode): $message';
}

/// Thrown when a 400 Bad Request response is received.
class BadRequestException extends ApiException {
  const BadRequestException({
    super.message = 'Yêu cầu không hợp lệ.',
    super.statusCode = 400,
  });

  @override
  String toString() => 'BadRequestException($statusCode): $message';
}

/// Thrown when a request times out.
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Yêu cầu đã hết thời gian chờ. Vui lòng thử lại.',
    super.statusCode,
  });

  @override
  String toString() => 'TimeoutException($statusCode): $message';
}
