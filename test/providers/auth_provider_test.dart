import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studify/providers/auth_provider.dart';

void main() {
  late AuthProvider authProvider;

  setUp(() {
    authProvider = AuthProvider();
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthProvider - Initial State', () {
    test('initial status should be initial', () {
      expect(authProvider.status, AuthStatus.initial);
    });

    test('initial user should be null', () {
      expect(authProvider.user, isNull);
    });

    test('initial errorMessage should be null', () {
      expect(authProvider.errorMessage, isNull);
    });

    test('initial isAuthenticated should be false', () {
      expect(authProvider.isAuthenticated, isFalse);
    });
  });

  group('AuthProvider - Check Auth Status', () {
    test('checkAuthStatus should set unauthenticated when no token', () async {
      // Act
      await authProvider.checkAuthStatus();

      // Assert
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.user, isNull);
    });

    test('checkAuthStatus should set authenticated when token exists',
        () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'test_token');
      await prefs.setString(
        'user_data',
        '{"id":1,"name":"Test User","email":"test@example.com","email_verified_at":null,"created_at":"2024-01-01T00:00:00.000000Z","updated_at":"2024-01-01T00:00:00.000000Z"}',
      );

      // Act
      await authProvider.checkAuthStatus();

      // Assert
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.name, 'Test User');
    });
  });

  group('AuthProvider - Logout', () {
    test('logout should clear user and set status to unauthenticated',
        () async {
      // Arrange - Setup authenticated state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'test_token');
      await prefs.setString(
        'user_data',
        '{"id":1,"name":"Test User","email":"test@example.com","email_verified_at":null,"created_at":"2024-01-01T00:00:00.000000Z","updated_at":"2024-01-01T00:00:00.000000Z"}',
      );
      await authProvider.checkAuthStatus();

      expect(authProvider.status, AuthStatus.authenticated);

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.user, isNull);
      expect(authProvider.errorMessage, isNull);

      // Verify SharedPreferences is cleared
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');
      expect(token, isNull);
      expect(userData, isNull);
    });
  });

  group('AuthProvider - State Changes', () {
    test('should notify listeners when status changes', () async {
      var notified = false;
      authProvider.addListener(() {
        notified = true;
      });

      // Act
      await authProvider.checkAuthStatus();

      // Assert
      expect(notified, isTrue);
    });
  });
}
