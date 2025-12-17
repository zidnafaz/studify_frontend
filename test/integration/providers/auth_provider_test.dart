import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studify/data/models/auth_response.dart';
import 'package:studify/data/models/user_model.dart';
import 'package:studify/providers/auth_provider.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthService = MockAuthService();
    authProvider = AuthProvider(authService: mockAuthService);
  });

  group('AuthProvider Integration Tests', () {
    final testUser = User(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
    );

    final testAuthResponse = AuthResponse(
      accessToken: 'token',
      refreshToken: 'refresh_token',
      user: testUser,
      tokenType: 'Bearer',
      expiresIn: 3600,
    );

    test('checkAuthStatus sets status to authenticated when user is logged in',
        () async {
      // Arrange
      when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
      when(mockAuthService.getUserData()).thenAnswer((_) async => testUser);

      // Act
      await authProvider.checkAuthStatus();

      // Assert
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.user, testUser);
      verify(mockAuthService.isAuthenticated()).called(1);
      verify(mockAuthService.getUserData()).called(1);
    });

    test('checkAuthStatus sets status to unauthenticated when user is not logged in',
        () async {
      // Arrange
      when(mockAuthService.isAuthenticated()).thenAnswer((_) async => false);

      // Act
      await authProvider.checkAuthStatus();

      // Assert
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.user, null);
      verify(mockAuthService.isAuthenticated()).called(1);
      verifyNever(mockAuthService.getUserData());
    });

    test('login success sets status to authenticated', () async {
      // Arrange
      when(mockAuthService.login(
        email: 'test@example.com',
        password: 'password',
      )).thenAnswer((_) async => testAuthResponse);

      // Act
      final result = await authProvider.login(
        email: 'test@example.com',
        password: 'password',
      );

      // Assert
      expect(result, true);
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.user, testUser);
      verify(mockAuthService.login(
        email: 'test@example.com',
        password: 'password',
      )).called(1);
    });
  });
}
