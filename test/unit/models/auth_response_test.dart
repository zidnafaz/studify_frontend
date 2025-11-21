import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/auth_response.dart';
import 'package:studify/data/models/user_model.dart';

void main() {
  group('AuthResponse Model Tests', () {
    test('should create AuthResponse from valid JSON', () {
      // Arrange
      final json = {
        'user': {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'email_verified_at': null,
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
        'access_token': 'test_token_123',
        'token_type': 'Bearer',
        'expires_in': 3600,
      };

      // Act
      final authResponse = AuthResponse.fromJson(json);

      // Assert
      expect(authResponse.user.id, 1);
      expect(authResponse.user.name, 'John Doe');
      expect(authResponse.user.email, 'john@example.com');
      expect(authResponse.accessToken, 'test_token_123');
      expect(authResponse.tokenType, 'Bearer');
      expect(authResponse.expiresIn, 3600);
    });

    test('should convert AuthResponse to JSON', () {
      // Arrange
      final user = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        emailVerifiedAt: null,
        createdAt: '2024-01-01T00:00:00.000000Z',
        updatedAt: '2024-01-01T00:00:00.000000Z',
      );

      final authResponse = AuthResponse(
        user: user,
        accessToken: 'test_token_123',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      // Act
      final json = authResponse.toJson();

      // Assert
      expect(json['user'], isA<User>());
      expect(json['access_token'], 'test_token_123');
      expect(json['token_type'], 'Bearer');
      expect(json['expires_in'], 3600);
      
      // Verify user data through the object
      final userInResponse = json['user'] as User;
      expect(userInResponse.id, 1);
      expect(userInResponse.name, 'John Doe');
      expect(userInResponse.email, 'john@example.com');
    });

    test('should handle different token types', () {
      // Arrange
      final json = {
        'user': {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'email_verified_at': null,
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
        'access_token': 'jwt_token_xyz',
        'token_type': 'JWT',
        'expires_in': 7200,
      };

      // Act
      final authResponse = AuthResponse.fromJson(json);

      // Assert
      expect(authResponse.tokenType, 'JWT');
      expect(authResponse.expiresIn, 7200);
    });

    test('should preserve user data in AuthResponse', () {
      // Arrange
      final json = {
        'user': {
          'id': 5,
          'name': 'Test User',
          'email': 'test@example.com',
          'email_verified_at': '2024-01-01T12:00:00.000000Z',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
        'access_token': 'access_token',
        'token_type': 'Bearer',
        'expires_in': 3600,
      };

      // Act
      final authResponse = AuthResponse.fromJson(json);

      // Assert
      expect(authResponse.user.emailVerifiedAt, '2024-01-01T12:00:00.000000Z');
      expect(authResponse.user.id, 5);
    });
  });
}
