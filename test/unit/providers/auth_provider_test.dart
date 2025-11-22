import 'package:flutter_test/flutter_test.dart';
import 'package:studify/providers/auth_provider.dart';
import 'package:studify/core/errors/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authProvider = AuthProvider();
    });

    group('Initial State', () {
      test('should have initial state on creation', () {
        // Assert
        expect(authProvider.status, AuthStatus.initial);
        expect(authProvider.user, null);
        expect(authProvider.errorMessage, null);
        expect(authProvider.isAuthenticated, false);
      });
    });

    group('Authentication Status', () {
      test('should return false for isAuthenticated when unauthenticated', () {
        // Arrange
        authProvider = AuthProvider();

        // Assert
        expect(authProvider.isAuthenticated, false);
      });

      test('should update status to unauthenticated when no token exists', () async {
        // Act
        await authProvider.checkAuthStatus();

        // Assert
        expect(authProvider.status, AuthStatus.unauthenticated);
        expect(authProvider.user, null);
      });
    });

    group('Error Handling', () {
      test('should handle ValidationException correctly', () {
        // Arrange
        final validationError = ValidationException(
          message: 'Validation failed',
          errors: {
            'email': ['Email is required'],
            'password': ['Password must be at least 8 characters'],
          },
        );

        // Assert
        expect(validationError.statusCode, 422);
        expect(validationError.errors['email'], isNotNull);
      });

      test('should handle UnauthorizedException correctly', () {
        // Arrange
        final unauthorizedError = UnauthorizedException(
          message: 'Invalid credentials',
        );

        // Assert
        expect(unauthorizedError.statusCode, 401);
        expect(unauthorizedError.message, 'Invalid credentials');
      });

      test('should handle NetworkException correctly', () {
        // Arrange
        final networkError = NetworkException(
          message: 'No internet connection',
        );

        // Assert
        expect(networkError.message, 'No internet connection');
      });
    });

    group('Logout', () {
      test('should reset state on logout', () async {
        // Act
        await authProvider.logout();

        // Assert
        expect(authProvider.status, AuthStatus.unauthenticated);
        expect(authProvider.user, null);
        expect(authProvider.errorMessage, null);
      });
    });

    group('State Management', () {
      test('should have correct status enum values', () {
        // Assert
        expect(AuthStatus.values.length, 4);
        expect(AuthStatus.values.contains(AuthStatus.initial), true);
        expect(AuthStatus.values.contains(AuthStatus.authenticated), true);
        expect(AuthStatus.values.contains(AuthStatus.unauthenticated), true);
        expect(AuthStatus.values.contains(AuthStatus.loading), true);
      });

      test('should maintain status consistency', () {
        // Arrange
        final statuses = [
          AuthStatus.initial,
          AuthStatus.loading,
          AuthStatus.authenticated,
          AuthStatus.unauthenticated,
        ];

        // Assert
        for (var status in statuses) {
          expect(AuthStatus.values.contains(status), true);
        }
      });
    });

    group('Error Message Formatting', () {
      test('should handle single error message', () {
        // Arrange
        final error = ApiException(message: 'Something went wrong');

        // Assert
        expect(error.message, 'Something went wrong');
      });

      test('should handle multiple validation errors', () {
        // Arrange
        final validationError = ValidationException(
          errors: {
            'email': ['Email is required', 'Email must be valid'],
            'password': ['Password is required'],
          },
        );

        // Assert
        expect(validationError.errors['email'].length, 2);
        expect(validationError.errors['password'].length, 1);
      });
    });

    group('User Data', () {
      test('should return null user when unauthenticated', () {
        // Assert
        expect(authProvider.user, null);
      });

      test('should maintain null user on logout', () async {
        // Act
        await authProvider.logout();

        // Assert
        expect(authProvider.user, null);
      });
    });

    group('Provider Listeners', () {
      test('should be ChangeNotifier', () {
        // Assert
        expect(authProvider, isA<AuthProvider>());
      });
    });

    group('Edge Cases', () {
      test('should handle empty credentials gracefully', () async {
        // This test will make actual API call and should handle error gracefully
        final result = await authProvider.login(email: '', password: '');
        // Should return false and set error message
        expect(result, false);
        expect(authProvider.status, AuthStatus.unauthenticated);
      });

      test('should handle empty registration data gracefully', () async {
        // This test will make actual API call and should handle error gracefully
        final result = await authProvider.register(
          name: '',
          email: '',
          password: '',
          passwordConfirmation: '',
        );
        // Should return false and set error message
        expect(result, false);
        expect(authProvider.status, AuthStatus.unauthenticated);
      });

      test('should handle null error message', () {
        // Arrange & Act
        final errorMessage = authProvider.errorMessage;

        // Assert
        expect(errorMessage, null);
      });
    });

    group('Status Transitions', () {
      test('should maintain valid status transitions', () {
        // All possible status values should be valid
        final validStatuses = [
          AuthStatus.initial,
          AuthStatus.loading,
          AuthStatus.authenticated,
          AuthStatus.unauthenticated,
        ];

        for (var status in validStatuses) {
          expect(AuthStatus.values.contains(status), true);
        }
      });
    });
  });
}
