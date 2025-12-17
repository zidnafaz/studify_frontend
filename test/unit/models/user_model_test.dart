import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/user_model.dart';

void main() {
  group('User Model Test', () {
    test('fromJson creates a valid User object', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'email_verified_at': '2023-01-01T00:00:00.000000Z',
        'created_at': '2023-01-01T00:00:00.000000Z',
        'updated_at': '2023-01-01T00:00:00.000000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.emailVerifiedAt, '2023-01-01T00:00:00.000000Z');
    });

    test('toJson creates a valid Map', () {
      final user = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        emailVerifiedAt: '2023-01-01T00:00:00.000000Z',
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['email_verified_at'], '2023-01-01T00:00:00.000000Z');
    });
  });
}
