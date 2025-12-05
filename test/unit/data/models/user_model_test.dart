import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    test('should create User from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'email_verified_at': null,
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, 1);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.emailVerifiedAt, null);
      expect(user.createdAt, '2024-01-01T00:00:00.000000Z');
      expect(user.updatedAt, '2024-01-01T00:00:00.000000Z');
    });

    test('should create User with verified email', () {
      // Arrange
      final json = {
        'id': 2,
        'name': 'Jane Doe',
        'email': 'jane@example.com',
        'email_verified_at': '2024-01-01T12:00:00.000000Z',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, 2);
      expect(user.name, 'Jane Doe');
      expect(user.email, 'jane@example.com');
      expect(user.emailVerifiedAt, '2024-01-01T12:00:00.000000Z');
    });

    test('should convert User to JSON', () {
      // Arrange
      final user = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        emailVerifiedAt: null,
        createdAt: '2024-01-01T00:00:00.000000Z',
        updatedAt: '2024-01-01T00:00:00.000000Z',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['email_verified_at'], null);
      expect(json['created_at'], '2024-01-01T00:00:00.000000Z');
      expect(json['updated_at'], '2024-01-01T00:00:00.000000Z');
    });

    test('should handle User equality correctly', () {
      // Arrange
      final user1 = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: '2024-01-01T00:00:00.000000Z',
        updatedAt: '2024-01-01T00:00:00.000000Z',
      );

      final user2 = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: '2024-01-01T00:00:00.000000Z',
        updatedAt: '2024-01-01T00:00:00.000000Z',
      );

      final user3 = User(
        id: 2,
        name: 'Jane Doe',
        email: 'jane@example.com',
        createdAt: '2024-01-01T00:00:00.000000Z',
        updatedAt: '2024-01-01T00:00:00.000000Z',
      );

      // Assert
      expect(user1.id == user2.id, true);
      expect(user1.id == user3.id, false);
    });
  });
}
