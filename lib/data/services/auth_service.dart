import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

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
      
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: ApiConstants.headers(),
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      return _handleAuthResponse(response);
    } catch (e) {
      print('❌ Register error: $e');
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
      
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.headers(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      return _handleAuthResponse(response);
    } catch (e) {
      print('❌ Login error: $e');
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await getToken();
      
      if (token != null) {
        final uri = Uri.parse(ApiConstants.logout);
        final request = http.Request('DELETE', uri);
        request.headers.addAll(ApiConstants.headers(token: token));
        
        await http.Client().send(request);
      }
      
      await clearAuthData();
    } catch (e) {
      // Even if API call fails, clear local data
      await clearAuthData();
      throw _handleError(e);
    }
  }

  // Get Current User
  Future<User> getCurrentUser() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      final response = await http.get(
        Uri.parse(ApiConstants.me),
        headers: ApiConstants.headers(token: token),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return User.fromJson(jsonData['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ApiException(
          message: 'Failed to get user data',
          statusCode: response.statusCode,
        );
      }
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

      final response = await http.post(
        Uri.parse(ApiConstants.refresh),
        headers: ApiConstants.headers(token: token),
      );

      return _handleAuthResponse(response);
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
  AuthResponse _handleAuthResponse(http.Response response) {
    print('🔍 Parsing response...');
    
    // Check if response is empty
    if (response.body.isEmpty) {
      print('❌ Response body is empty');
      throw ApiException(
        message: 'Server returned empty response. Backend mungkin belum siap atau URL salah.',
      );
    }

    try {
      final jsonData = json.decode(response.body);
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
    } on FormatException catch (e) {
      print('❌ JSON parse error: $e');
      print('📄 Raw response: ${response.body}');
      throw ApiException(
        message: 'Invalid response format dari server. Kemungkinan backend belum deploy dengan benar atau URL salah.\n\nResponse: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );
    }
  }

  // Handle Error
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is http.ClientException) {
      return NetworkException(message: 'Network error: ${error.message}');
    } else {
      return ApiException(message: error.toString());
    }
  }
}
