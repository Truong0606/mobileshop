import 'package:dio/dio.dart';

import 'package:smart_shopping_chatbot/core/config/app_config.dart';
import 'api_exceptions.dart';

/// Singleton HTTP client built on top of [Dio].
///
/// Provides convenient typed methods (`get`, `post`, `put`, `delete`) with
/// built-in error mapping to [ApiException] subtypes.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.apiBaseUrl,
        // Render free tier may cold-start in 30-60s, so use generous timeouts
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([_authInterceptor(), _loggingInterceptor()]);
  }

  static final ApiClient _instance = ApiClient._internal();

  /// The shared [ApiClient] singleton.
  static ApiClient get instance => _instance;

  late final Dio _dio;

  /// Auth token – set after login, cleared on logout.
  String? _authToken;

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  /// Callback fired when a 401 Unauthorized response is received.
  void Function()? onUnauthorized;

  // ───────── Interceptors ─────────

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          onUnauthorized?.call();
        }
        handler.next(e);
      },
    );
  }

  Interceptor _loggingInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        // In production you would use a proper logger.
        // ignore: avoid_print
        print('[API] $obj');
      },
    );
  }

  // ───────── Public API ─────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.get<T>(path, queryParameters: queryParameters, options: options),
  );

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
  );

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
  );

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
  );

  // ───────── Error mapping ─────────

  Future<Response<T>> _request<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  ApiException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Network error. Please check your connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        final serverMessage = data is Map ? (data['message'] as String?) : null;

        if (statusCode == 401) {
          return UnauthorizedException(
            message: serverMessage ?? 'Unauthorized. Please log in again.',
          );
        }
        if (statusCode == 404) {
          return NotFoundException(
            message: serverMessage ?? 'Resource not found.',
          );
        }
        return ServerException(
          message: serverMessage ?? 'Server error ($statusCode)',
          statusCode: statusCode,
        );
      default:
        return ApiException(
          message: e.message ?? 'An unexpected error occurred.',
        );
    }
  }
}
