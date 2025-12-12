import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/classroom_model.dart';
import 'package:studify/data/models/user_model.dart';

void main() {
  group('Classroom Model Tests', () {
    test('Should successfully parse String id as int', () {
      final json = {
        'id': '1', // String instead of int
        'owner_id': 1,
        'name': 'Test Class',
        'unique_code': 'ABC1234',
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-01-01T00:00:00.000Z',
      };

      final classroom = Classroom.fromJson(json);
      expect(classroom.id, 1);
    });

    test('Should successfully parse String owner_id as int', () {
      final json = {
        'id': 1,
        'owner_id': '1', // String instead of int
        'name': 'Test Class',
        'unique_code': 'ABC1234',
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-01-01T00:00:00.000Z',
      };

      final classroom = Classroom.fromJson(json);
      expect(classroom.ownerId, 1);
    });
  });
}
