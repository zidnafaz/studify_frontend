import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/classroom_model.dart';

void main() {
  group('Classroom Model Test', () {
    test('fromJson creates a valid Classroom object', () {
      final json = {
        'id': 1,
        'owner_id': 10,
        'name': 'Math 101',
        'unique_code': 'MATH101',
        'description': 'Basic Math',
        'created_at': '2023-01-01T00:00:00.000000Z',
        'updated_at': '2023-01-01T00:00:00.000000Z',
      };

      final classroom = Classroom.fromJson(json);

      expect(classroom.id, 1);
      expect(classroom.ownerId, 10);
      expect(classroom.name, 'Math 101');
      expect(classroom.uniqueCode, 'MATH101');
      expect(classroom.description, 'Basic Math');
      expect(classroom.createdAt, isA<DateTime>());
    });

    test('toJson creates a valid Map', () {
      final classroom = Classroom(
        id: 1,
        ownerId: 10,
        name: 'Math 101',
        uniqueCode: 'MATH101',
        description: 'Basic Math',
        createdAt: DateTime.parse('2023-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2023-01-01T00:00:00.000000Z'),
      );

      final json = classroom.toJson();

      expect(json['id'], 1);
      expect(json['owner_id'], 10);
      expect(json['name'], 'Math 101');
      expect(json['unique_code'], 'MATH101');
    });
  });
}
