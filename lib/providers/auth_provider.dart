import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../core/errors/api_exception.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  // public getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // -------------------------
  // PRIVATE HELPERS
  // -------------------------

  void _setStatus(AuthStatus status) {
    _status = status;
  }

  void _setUser(User? user) {
    _user = user;
  }

  void _setError(String? message) {
    _errorMessage = message;
  }

  /// Helper to execute an async operation with consistent status + error handling.
  /// [operation] should perform changes to provider state but NOT call notifyListeners().
  /// notifyOnce: whether this wrapper should call notifyListeners at the end.
  Future<T> _withStatus<T>(
    Future<T> Function() operation, {
    AuthStatus? initialStatus,
    bool notifyOnce = true,
  }) async {
    if (initialStatus != null) {
      _setStatus(initialStatus);
    }
    _setError(null);
    if (notifyOnce) notifyListeners();

    try {
      final res = await operation();
      return res;
    } on ValidationException catch (e) {
      _setStatus(AuthStatus.unauthenticated);
      _setError(_formatValidationErrors(e.errors));
      if (notifyOnce) notifyListeners();
      rethrow;
    } on UnauthorizedException catch (e) {
      _setStatus(AuthStatus.unauthenticated);
      _setError(e.message);
      if (notifyOnce) notifyListeners();
      rethrow;
    } on ApiException catch (e) {
      _setStatus(AuthStatus.unauthenticated);
      _setError(e.message);
      if (notifyOnce) notifyListeners();
      rethrow;
    } catch (e) {
      _setStatus(AuthStatus.unauthenticated);
      _setError('An unexpected error occurred');
      if (notifyOnce) notifyListeners();
      rethrow;
    }
  }

  // -------------------------
  // API METHODS (safe)
  // -------------------------

  // Check Authentication Status
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        final userData = await _authService.getUserData();
        if (userData != null) {
          _setUser(userData);
          _setStatus(AuthStatus.authenticated);
        } else {
          _setStatus(AuthStatus.unauthenticated);
        }
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }

      notifyListeners();
    } catch (e) {
      _setStatus(AuthStatus.unauthenticated);
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
      return await _withStatus(() async {
        final authResponse = await _authService.register(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );

        _setUser(authResponse.user);
        _setStatus(AuthStatus.authenticated);
        notifyListeners();
        return true;
      }, initialStatus: AuthStatus.loading);
    } on ValidationException {
      return false;
    } on ApiException {
      return false;
    } catch (e) {
      return false;
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    try {
      return await _withStatus(() async {
        final authResponse = await _authService.login(
          email: email,
          password: password,
        );

        _setUser(authResponse.user);
        _setStatus(AuthStatus.authenticated);
        notifyListeners();
        return true;
      }, initialStatus: AuthStatus.loading);
    } on ValidationException {
      return false;
    } on UnauthorizedException {
      return false;
    } on ApiException {
      return false;
    } catch (e) {
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
      _setUser(null);
      _setStatus(AuthStatus.unauthenticated);
      _setError(null);
      notifyListeners();
    }
  }

  // Update Profile
  Future<bool> updateProfile({required String name}) async {
    try {
      return await _withStatus(() async {
        final updatedUser = await _authService.updateProfile(name: name);

        _setUser(updatedUser);
        _setStatus(AuthStatus.authenticated);
        notifyListeners();
        return true;
      }, initialStatus: AuthStatus.loading);
    } on ValidationException {
      return false;
    } on ApiException {
      return false;
    } catch (e) {
      return false;
    }
  }

  // Refresh Token
  Future<void> refreshToken() async {
    try {
      final authResponse = await _authService.refreshToken();
      _setUser(authResponse.user);
      notifyListeners();
    } catch (e) {
      // If refresh fails, logout
      await logout();
    }
  }

  // Clear Error
  void clearError() {
    _setError(null);
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
