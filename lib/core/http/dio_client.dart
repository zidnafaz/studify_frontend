import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../errors/api_exception.dart';
import '../../data/services/auth_service.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  final AuthService _authService = AuthService();
  bool _isRefreshing = false;
  final List<({Completer completer, RequestOptions options})> _pendingRequests =
      [];

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to request if available
          final token = await _authService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add Accept-Language header
          final prefs = await SharedPreferences.getInstance();
          final languageCode = prefs.getString('language_code') ?? 'en';
          options.headers['Accept-Language'] = languageCode;

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - try to refresh token
          if (error.response?.statusCode == 401) {
            print(
              '🔒 401 Unauthorized intercepted for ${error.requestOptions.path}',
            );
            // Skip refresh for auth endpoints (login, register, refresh)
            final path = error.requestOptions.path;
            if (path.contains('/api/auth/login') ||
                path.contains('/api/auth/refresh') ||
                path.contains('/api/users')) {
              return handler.next(error);
            }

            // Check if this request was already a retry
            if (error.requestOptions.extra['is_retry'] == true) {
              // If a retry fails with 401, it means the new token is also invalid or something else is wrong.
              // Don't try to refresh again to avoid infinite loop.
              return handler.next(error);
            }

            // If already refreshing, queue this request
            if (_isRefreshing) {
              final completer = Completer<Response>();
              _pendingRequests.add((
                completer: completer,
                options: error.requestOptions,
              ));
              try {
                final response = await completer.future;
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }

            // Start token refresh
            _isRefreshing = true;
            print('🔄 Starting token refresh...');
            try {
              final authResponse = await _authService.refreshToken();
              final newToken = authResponse.accessToken;

              // Update the failed request with new token
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';

              // Retry the original request
              final opts = Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
                extra: {...error.requestOptions.extra, 'is_retry': true},
              );
              final response = await _dio.request(
                error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );

              // Resolve all pending requests
              for (var pending in _pendingRequests) {
                // Update token for pending requests
                pending.options.headers['Authorization'] = 'Bearer $newToken';
                try {
                  final pendingResponse = await _dio.request(
                    pending.options.path,
                    options: Options(
                      method: pending.options.method,
                      headers: pending.options.headers,
                      extra: {...pending.options.extra, 'is_retry': true},
                    ),
                    data: pending.options.data,
                    queryParameters: pending.options.queryParameters,
                  );
                  pending.completer.complete(pendingResponse);
                } catch (e) {
                  pending.completer.completeError(e);
                }
              }
              _pendingRequests.clear();
              _isRefreshing = false;
              print('✅ Token refresh successful, retrying requests...');

              return handler.resolve(response);
            } catch (e) {
              // Refresh failed, clear auth and reject all pending requests
              _isRefreshing = false;
              print('❌ Token refresh failed: $e');
              await _authService.clearAuthData();
              for (var pending in _pendingRequests) {
                pending.completer.completeError(e);
              }
              _pendingRequests.clear();
              return handler.next(error);
            }
          }

          // Handle other errors
          return handler.next(error);
        },
      ),
    );
  }

  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  // Helper methods for common HTTP methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException(message: 'Connection timeout');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException(message: 'No internet connection');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      if (statusCode == 401) {
        return UnauthorizedException(
          message: data is Map && data['message'] != null
              ? data['message']
              : 'Unauthorized access',
        );
      } else if (statusCode == 403) {
        return ForbiddenException(
          message: data is Map && data['message'] != null
              ? data['message']
              : 'Forbidden access',
        );
      } else if (statusCode == 404) {
        return NotFoundException(
          message: data is Map && data['message'] != null
              ? data['message']
              : 'Resource not found',
        );
      } else if (statusCode == 422) {
        return ValidationException(
          message: data is Map && data['message'] != null
              ? data['message']
              : 'Validation failed',
          errors: data is Map ? data['errors'] : null,
        );
      } else if (statusCode == 400) {
        return ApiException(
          message: data is Map && data['message'] != null
              ? data['message']
              : 'Bad request',
          statusCode: statusCode,
        );
      } else {
        return ApiException(
          message: data is Map && data['message'] != null
              ? data['message']
              : 'An error occurred',
          statusCode: statusCode,
        );
      }
    }

    return ApiException(
      message: error.message ?? 'An unexpected error occurred',
    );
  }
}
