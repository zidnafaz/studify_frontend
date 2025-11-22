import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Separate Dio instance for auth endpoints (no interceptors)
  late final Dio _authDio;
  
  AuthService() {
    _authDio = Dio(
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
  }

  // Register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      print('🔵 Register request to: ${ApiConstants.register}');
      print('📝 Data: name=$name, email=$email');
      
      final response = await _authDio.post(
        '/api/users',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');
      
      return _handleAuthResponse(response);
    } on DioException catch (e) {
      print('❌ Register error: $e');
      final exception = _handleDioError(e);
      if (exception is ApiException) {
        throw exception;
      }
      throw exception;
    } catch (e) {
      print('❌ Register error: $e');
      if (e is ApiException) {
        throw e;
      }
      throw _handleError(e);
    }
  }

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Login request to: ${ApiConstants.login}');
      print('📝 Email: $email');
      
      final response = await _authDio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');
      
      return _handleAuthResponse(response);
    } on DioException catch (e) {
      print('❌ Login error: $e');
      final exception = _handleDioError(e);
      if (exception is ApiException) {
        throw exception;
      }
      throw exception;
    } catch (e) {
      print('❌ Login error: $e');
      if (e is ApiException) {
        throw e;
      }
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await getToken();
      
      if (token != null) {
        await _authDio.delete(
          '/api/auth/login',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
      
      await clearAuthData();
    } catch (e) {
      // Even if API call fails, clear local data
      await clearAuthData();
      // Don't throw error on logout failure
      print('Logout error (ignored): $e');
    }
  }

  // Get Current User
  Future<User> getCurrentUser() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      final response = await _authDio.get(
        '/api/auth/user',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to get user data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Refresh Token
  Future<AuthResponse> refreshToken() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      final response = await _authDio.post(
        '/api/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return _handleAuthResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Save Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save User Data
  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Get User Data
  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    
    return null;
  }

  // Clear Auth Data
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Check if Authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Handle Auth Response
  AuthResponse _handleAuthResponse(Response response) {
    print('🔍 Parsing response...');
    
    // Check if response is empty
    if (response.data == null) {
      print('❌ Response body is empty');
      throw ApiException(
        message: 'Server returned empty response. Backend mungkin belum siap atau URL salah.',
      );
    }

    try {
      final jsonData = response.data;
      print('✅ JSON parsed successfully');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(jsonData['data']);
        
        // Save token and user data
        saveToken(authResponse.accessToken);
        saveUserData(authResponse.user);
        
        return authResponse;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: jsonData['message'] ?? 'Invalid credentials',
        );
      } else if (response.statusCode == 400) {
        // Handle 400 Bad Request - could be validation or bad input
        if (jsonData['errors'] != null) {
          throw ValidationException(
            message: jsonData['message'] ?? 'Validation failed',
            errors: jsonData['errors'],
          );
        }
        throw ApiException(
          message: jsonData['message'] ?? 'Bad request',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 422) {
        throw ValidationException(
          message: jsonData['message'] ?? 'Validation failed',
          errors: jsonData['errors'],
        );
      } else {
        throw ApiException(
          message: jsonData['message'] ?? 'An error occurred',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ JSON parse error: $e');
      print('📄 Raw response: ${response.data}');
      throw ApiException(
        message: 'Invalid response format dari server. Kemungkinan backend belum deploy dengan benar atau URL salah.',
      );
    }
  }

  // Handle Dio Error
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
              : 'Invalid credentials',
        );
      } else if (statusCode == 400) {
        // Handle 400 Bad Request - could be validation or bad input
        if (data is Map && data['errors'] != null) {
          return ValidationException(
            message: data['message'] != null
                ? data['message']
                : 'Validation failed',
            errors: data['errors'],
          );
        }
        return ApiException(
          message: data is Map && data['message'] != null
              ? data['message']
              : 'Bad request',
          statusCode: statusCode,
        );
      } else if (statusCode == 422) {
        return ValidationException(
          message: data is Map && data['message'] != null
              ? data['message']
              : 'Validation failed',
          errors: data is Map ? data['errors'] : null,
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

    return ApiException(message: error.message ?? 'An unexpected error occurred');
  }

  // Handle Error
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else {
      return ApiException(message: error.toString());
    }
  }
}
