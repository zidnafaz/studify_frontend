import 'package:studify/data/models/auth_response.dart';
import 'package:studify/data/models/user_model.dart';
import 'package:studify/data/services/auth_service.dart';

class FakeAuthService implements AuthService {
  bool _isAuth = false;
  User? _currentUser;

  // Pre-defined test user
  final User _testUser = User(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    emailVerifiedAt: '2023-01-01T00:00:00.000000Z',
    createdAt: '2023-01-01T00:00:00.000000Z',
    updatedAt: '2023-01-01T00:00:00.000000Z',
  );

  @override
  Future<bool> isAuthenticated() async {
    return _isAuth;
  }

  @override
  Future<User?> getUserData() async {
    return _isAuth ? _currentUser : null;
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    // Simple validation for test
    if (email == 'test@example.com' && password == 'password') {
      _isAuth = true;
      _currentUser = _testUser;
      return AuthResponse(
        user: _testUser,
        accessToken: 'fake_token',
        tokenType: 'Bearer',
        refreshToken: 'fake_refresh_token',
        expiresIn: 3600,
      );
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isAuth = true;
    _currentUser = User(
      id: 2,
      name: name,
      email: email,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    return AuthResponse(
      user: _currentUser!,
      accessToken: 'fake_token_register',
      tokenType: 'Bearer',
      refreshToken: 'fake_refresh_token_register',
      expiresIn: 3600,
    );
  }

  @override
  Future<void> logout() async {
    _isAuth = false;
    _currentUser = null;
  }

  @override
  Future<User> updateProfile({required String name}) async {
    _currentUser = User(
      id: _currentUser!.id,
      name: name,
      email: _currentUser!.email,
      emailVerifiedAt: _currentUser!.emailVerifiedAt,
      createdAt: _currentUser!.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    return _currentUser!;
  }

  @override
  Future<AuthResponse> refreshToken() async {
    if (!_isAuth) throw Exception('Not authenticated');
    return AuthResponse(
      user: _currentUser!,
      accessToken: 'fake_refreshed_token',
      tokenType: 'Bearer',
      refreshToken: 'fake_new_refresh_token',
      expiresIn: 3600,
    );
  }

  @override
  Future<void> clearAuthData() async {
    _isAuth = false;
    _currentUser = null;
  }

  @override
  Future<User> getCurrentUser() async {
    if (_currentUser == null) throw Exception('No user');
    return _currentUser!;
  }

  @override
  Future<String?> getRefreshToken() async {
    return 'fake_refresh_token';
  }

  @override
  Future<String?> getToken() async {
    return 'fake_token';
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {}

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> saveUserData(User user) async {
    _currentUser = user;
  }
}
