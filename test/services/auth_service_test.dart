import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studify/data/services/auth_service.dart';
import 'package:studify/data/models/user_model.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService - Token Management', () {
    test('saveToken and getToken should work correctly', () async {
      // Act
      await authService.saveToken('test_token');
      final token = await authService.getToken();

      // Assert
      expect(token, 'test_token');
    });

    test('saveUserData and getUserData should work correctly', () async {
      // Arrange
      final user = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: '2024-01-01T00:00:00.000000Z',
        updatedAt: '2024-01-01T00:00:00.000000Z',
      );

      // Act
      await authService.saveUserData(user);
      final retrievedUser = await authService.getUserData();

      // Assert
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.name, 'Test User');
      expect(retrievedUser.email, 'test@example.com');
    });

    test('clearAuthData should remove token and user data', () async {
      // Arrange
      await authService.saveToken('test_token');
      await authService.saveUserData(User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: '2024-01-01T00:00:00.000000Z',
        updatedAt: '2024-01-01T00:00:00.000000Z',
      ));

      // Act
      await authService.clearAuthData();
      final token = await authService.getToken();
      final user = await authService.getUserData();

      // Assert
      expect(token, isNull);
      expect(user, isNull);
    });

    test('isAuthenticated should return true when token exists', () async {
      // Arrange
      await authService.saveToken('test_token');

      // Act
      final isAuth = await authService.isAuthenticated();

      // Assert
      expect(isAuth, isTrue);
    });

    test('isAuthenticated should return false when no token', () async {
      // Act
      final isAuth = await authService.isAuthenticated();

      // Assert
      expect(isAuth, isFalse);
    });
  });

  group('AuthService - Logout', () {
    test('logout should clear auth data', () async {
      // Arrange
      await authService.saveToken('test_token');
      await authService.saveUserData(User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: '2024-01-01T00:00:00.000000Z',
        updatedAt: '2024-01-01T00:00:00.000000Z',
      ));

      // Act
      await authService.logout();
      final token = await authService.getToken();
      final user = await authService.getUserData();

      // Assert
      expect(token, isNull);
      expect(user, isNull);
    });
  });
}
