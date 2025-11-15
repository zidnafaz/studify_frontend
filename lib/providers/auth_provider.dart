import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../core/errors/api_exception.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Check Authentication Status
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        final userData = await _authService.getUserData();
        if (userData != null) {
          _user = userData;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
      
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      _user = authResponse.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      
      return true;
    } on ValidationException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _formatValidationErrors(e.errors);
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _user = authResponse.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      
      return true;
    } on ValidationException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _formatValidationErrors(e.errors);
      notifyListeners();
      return false;
    } on UnauthorizedException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Log error but still continue with logout
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Refresh Token
  Future<void> refreshToken() async {
    try {
      final authResponse = await _authService.refreshToken();
      _user = authResponse.user;
      notifyListeners();
    } catch (e) {
      // If refresh fails, logout
      await logout();
    }
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Format Validation Errors
  String _formatValidationErrors(dynamic errors) {
    if (errors == null) return 'Validation failed';
    
    if (errors is Map) {
      final errorMessages = <String>[];
      errors.forEach((key, value) {
        if (value is List) {
          errorMessages.addAll(value.cast<String>());
        } else {
          errorMessages.add(value.toString());
        }
      });
      return errorMessages.join('\n');
    }
    
    return errors.toString();
  }
}
