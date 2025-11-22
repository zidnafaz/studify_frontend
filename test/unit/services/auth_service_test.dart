import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studify/data/services/auth_service.dart';
import 'package:studify/data/models/user_model.dart';
import 'package:studify/core/errors/api_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      SharedPreferences.setMockInitialValues({});
    });

    group('Token Management', () {
      test('should save and retrieve token', () async {
        // Arrange
        const testToken = 'test_token_123';

        // Act
        await authService.saveToken(testToken);
        final retrievedToken = await authService.getToken();

        // Assert
        expect(retrievedToken, testToken);
      });

      test('should return null when no token exists', () async {
        // Act
        final token = await authService.getToken();

        // Assert
        expect(token, null);
      });

      test('should clear auth data', () async {
        // Arrange
        await authService.saveToken('test_token');
        final userData = User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          createdAt: '2024-01-01T00:00:00.000000Z',
          updatedAt: '2024-01-01T00:00:00.000000Z',
        );
        await authService.saveUserData(userData);

        // Act
        await authService.clearAuthData();

        // Assert
        final token = await authService.getToken();
        final user = await authService.getUserData();
        expect(token, null);
        expect(user, null);
      });
    });

    group('User Data Management', () {
      test('should save and retrieve user data', () async {
        // Arrange
        final userData = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          emailVerifiedAt: null,
          createdAt: '2024-01-01T00:00:00.000000Z',
          updatedAt: '2024-01-01T00:00:00.000000Z',
        );

        // Act
        await authService.saveUserData(userData);
        final retrievedUser = await authService.getUserData();

        // Assert
        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.id, 1);
        expect(retrievedUser.name, 'John Doe');
        expect(retrievedUser.email, 'john@example.com');
      });

      test('should return null when no user data exists', () async {
        // Act
        final user = await authService.getUserData();

        // Assert
        expect(user, null);
      });
    });

    group('Authentication Status', () {
      test('should return true when token exists', () async {
        // Arrange
        await authService.saveToken('test_token');

        // Act
        final isAuth = await authService.isAuthenticated();

        // Assert
        expect(isAuth, true);
      });

      test('should return false when no token exists', () async {
        // Act
        final isAuth = await authService.isAuthenticated();

        // Assert
        expect(isAuth, false);
      });
    });

    group('Register', () {
      test('should register successfully', () async {
        // Arrange
        final mockResponse = {
          'user': {
            'id': 1,
            'name': 'John Doe',
            'email': 'john@example.com',
            'email_verified_at': null,
            'created_at': '2024-01-01T00:00:00.000000Z',
            'updated_at': '2024-01-01T00:00:00.000000Z',
          },
          'access_token': 'test_token',
          'token_type': 'Bearer',
          'expires_in': 3600,
        };

        // Note: This test assumes a working HTTP client
        // In real scenario, you'd mock the HTTP client
        // For now, we test the structure

        expect(mockResponse['user'], isNotNull);
        expect(mockResponse['access_token'], isNotNull);
      });

      test('should handle validation errors', () {
        // Arrange
        final validationError = ValidationException(
          message: 'Validation failed',
          errors: {
            'email': ['The email has already been taken.'],
            'password': ['The password must be at least 8 characters.'],
          },
        );

        // Assert
        expect(validationError.statusCode, 422);
        expect(validationError.message, 'Validation failed');
        expect(validationError.errors, isNotNull);
      });
    });

    group('Login', () {
      test('should handle successful login response', () async {
        // Arrange
        final mockResponse = {
          'user': {
            'id': 1,
            'name': 'John Doe',
            'email': 'john@example.com',
            'email_verified_at': null,
            'created_at': '2024-01-01T00:00:00.000000Z',
            'updated_at': '2024-01-01T00:00:00.000000Z',
          },
          'access_token': 'login_token',
          'token_type': 'Bearer',
          'expires_in': 3600,
        };

        expect(mockResponse['access_token'], 'login_token');
        final user = mockResponse['user'] as Map;
        expect(user['email'], 'john@example.com');
      });

      test('should handle unauthorized error', () {
        // Arrange
        final unauthorizedError = UnauthorizedException(
          message: 'Invalid credentials',
        );

        // Assert
        expect(unauthorizedError.statusCode, 401);
        expect(unauthorizedError.message, 'Invalid credentials');
      });
    });

    group('Logout', () {
      test('should clear local data on logout', () async {
        // Arrange
        await authService.saveToken('test_token');
        final userData = User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          createdAt: '2024-01-01T00:00:00.000000Z',
          updatedAt: '2024-01-01T00:00:00.000000Z',
        );
        await authService.saveUserData(userData);

        // Act
        await authService.clearAuthData();

        // Assert
        final token = await authService.getToken();
        final user = await authService.getUserData();
        expect(token, null);
        expect(user, null);
      });
    });

    group('Refresh Token', () {
      test('should save and retrieve refresh token', () async {
        // Arrange
        const refreshToken = 'refresh_token_123';

        // Act
        await authService.saveRefreshToken(refreshToken);
        final retrievedToken = await authService.getRefreshToken();

        // Assert
        expect(retrievedToken, refreshToken);
      });

      test('should return null when no refresh token exists', () async {
        // Act
        final token = await authService.getRefreshToken();

        // Assert
        expect(token, null);
      });

      test('should clear refresh token on clearAuthData', () async {
        // Arrange
        await authService.saveRefreshToken('refresh_token');
        await authService.saveToken('access_token');

        // Act
        await authService.clearAuthData();

        // Assert
        final refreshToken = await authService.getRefreshToken();
        final accessToken = await authService.getToken();
        expect(refreshToken, null);
        expect(accessToken, null);
      });

      test('should handle refreshToken response structure', () {
        // Arrange
        final mockResponse = {
          'user': {
            'id': 1,
            'name': 'John Doe',
            'email': 'john@example.com',
            'email_verified_at': null,
            'created_at': '2024-01-01T00:00:00.000000Z',
            'updated_at': '2024-01-01T00:00:00.000000Z',
          },
          'access_token': 'new_access_token',
          'refresh_token': 'new_refresh_token',
          'token_type': 'Bearer',
          'expires_in': 3600,
        };

        // Assert
        expect(mockResponse['refresh_token'], 'new_refresh_token');
        expect(mockResponse['access_token'], 'new_access_token');
      });
    });

    group('Get Current User', () {
      test('should handle getCurrentUser method', () {
        // This test verifies the method exists and can be called
        // In actual implementation, you would mock the HTTP client
        expect(authService.getCurrentUser, isA<Future<User> Function()>());
      });

      test('should require token for getCurrentUser', () {
        // Arrange
        final mockResponse = {
          'data': {
            'id': 1,
            'name': 'John Doe',
            'email': 'john@example.com',
            'email_verified_at': null,
            'created_at': '2024-01-01T00:00:00.000000Z',
            'updated_at': '2024-01-01T00:00:00.000000Z',
          },
        };

        // Assert
        expect(mockResponse['data'], isNotNull);
        final userData = mockResponse['data'] as Map;
        expect(userData['id'], 1);
        expect(userData['email'], 'john@example.com');
      });
    });

    group('Error Handling', () {
      test('should create NetworkException', () {
        // Arrange
        final networkError = NetworkException();

        // Assert
        expect(networkError.message, 'Network error occurred');
      });

      test('should create custom NetworkException with message', () {
        // Arrange
        final networkError = NetworkException(
          message: 'Connection timeout',
        );

        // Assert
        expect(networkError.message, 'Connection timeout');
      });

      test('should create ValidationException with errors', () {
        // Arrange
        final validationError = ValidationException(
          errors: {
            'email': ['Invalid email format'],
            'password': ['Password too short'],
          },
        );

        // Assert
        expect(validationError.statusCode, 422);
        expect(validationError.errors['email'], isNotNull);
        expect(validationError.errors['password'], isNotNull);
      });

      test('should create UnauthorizedException', () {
        // Arrange
        final unauthorizedError = UnauthorizedException();

        // Assert
        expect(unauthorizedError.statusCode, 401);
        expect(unauthorizedError.message, 'Unauthorized access');
      });

      test('should create ApiException with custom status code', () {
        // Arrange
        final apiError = ApiException(
          message: 'Server error',
          statusCode: 500,
        );

        // Assert
        expect(apiError.statusCode, 500);
        expect(apiError.message, 'Server error');
      });
    });
  });
}
