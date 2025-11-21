import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/classroom_model.dart';

void main() {
  group('Classroom Model Tests', () {
    test('should create Classroom from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'owner_id': 1,
        'name': 'Test Classroom',
        'unique_code': 'ABC123',
        'description': 'Test description',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final classroom = Classroom.fromJson(json);

      // Assert
      expect(classroom.id, 1);
      expect(classroom.ownerId, 1);
      expect(classroom.name, 'Test Classroom');
      expect(classroom.uniqueCode, 'ABC123');
      expect(classroom.description, 'Test description');
      expect(classroom.createdAt, isA<DateTime>());
      expect(classroom.updatedAt, isA<DateTime>());
    });

    test('should create Classroom with null description', () {
      // Arrange
      final json = {
        'id': 2,
        'owner_id': 1,
        'name': 'Classroom Without Description',
        'unique_code': 'DEF456',
        'description': null,
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final classroom = Classroom.fromJson(json);

      // Assert
      expect(classroom.id, 2);
      expect(classroom.name, 'Classroom Without Description');
      expect(classroom.uniqueCode, 'DEF456');
      expect(classroom.description, isNull);
    });

    test('should create Classroom with owner', () {
      // Arrange
      final json = {
        'id': 3,
        'owner_id': 1,
        'name': 'Classroom With Owner',
        'unique_code': 'GHI789',
        'description': 'Test',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
        'owner': {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
      };

      // Act
      final classroom = Classroom.fromJson(json);

      // Assert
      expect(classroom.id, 3);
      expect(classroom.owner, isNotNull);
      expect(classroom.owner?.name, 'John Doe');
      expect(classroom.owner?.email, 'john@example.com');
    });

    test('should convert Classroom to JSON', () {
      // Arrange
      final classroom = Classroom(
        id: 1,
        ownerId: 1,
        name: 'Test Classroom',
        uniqueCode: 'ABC123',
        description: 'Test description',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = classroom.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['owner_id'], 1);
      expect(json['name'], 'Test Classroom');
      expect(json['unique_code'], 'ABC123');
      expect(json['description'], 'Test description');
      expect(json['created_at'], isA<String>());
      expect(json['updated_at'], isA<String>());
    });

    test('should convert Classroom with null fields to JSON', () {
      // Arrange
      final classroom = Classroom(
        id: 2,
        ownerId: 1,
        name: 'Test Classroom',
        uniqueCode: 'ABC123',
        description: null,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = classroom.toJson();

      // Assert
      expect(json['id'], 2);
      expect(json['description'], isNull);
    });

    test('should handle multiple classrooms in a list', () {
      // Arrange
      final jsonList = [
        {
          'id': 1,
          'owner_id': 1,
          'name': 'Classroom 1',
          'unique_code': 'ABC123',
          'description': 'First classroom',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
        {
          'id': 2,
          'owner_id': 1,
          'name': 'Classroom 2',
          'unique_code': 'DEF456',
          'description': 'Second classroom',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
      ];

      // Act
      final classrooms = jsonList.map((json) => Classroom.fromJson(json)).toList();

      // Assert
      expect(classrooms.length, 2);
      expect(classrooms[0].name, 'Classroom 1');
      expect(classrooms[0].uniqueCode, 'ABC123');
      expect(classrooms[1].name, 'Classroom 2');
      expect(classrooms[1].uniqueCode, 'DEF456');
    });

    test('should handle DateTime parsing correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'owner_id': 1,
        'name': 'Test Classroom',
        'unique_code': 'ABC123',
        'description': 'Test',
        'created_at': '2024-01-15T10:30:45.123456Z',
        'updated_at': '2024-01-16T14:25:30.654321Z',
      };

      // Act
      final classroom = Classroom.fromJson(json);

      // Assert
      expect(classroom.createdAt.year, 2024);
      expect(classroom.createdAt.month, 1);
      expect(classroom.createdAt.day, 15);
      expect(classroom.updatedAt.year, 2024);
      expect(classroom.updatedAt.month, 1);
      expect(classroom.updatedAt.day, 16);
    });

    test('should validate classroom properties', () {
      // Arrange & Act
      final classroom = Classroom(
        id: 1,
        ownerId: 1,
        name: 'Test Classroom',
        uniqueCode: 'ABC123',
        description: 'Test description',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Assert
      expect(classroom.id, isPositive);
      expect(classroom.ownerId, isPositive);
      expect(classroom.name, isNotEmpty);
      expect(classroom.uniqueCode, isNotEmpty);
      expect(classroom.uniqueCode.length, greaterThan(0));
    });

    test('should handle roundtrip JSON serialization', () {
      // Arrange
      final original = Classroom(
        id: 1,
        ownerId: 1,
        name: 'Test Classroom',
        uniqueCode: 'ABC123',
        description: 'Test description',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = original.toJson();
      final deserialized = Classroom.fromJson(json);

      // Assert
      expect(deserialized.id, original.id);
      expect(deserialized.ownerId, original.ownerId);
      expect(deserialized.name, original.name);
      expect(deserialized.uniqueCode, original.uniqueCode);
      expect(deserialized.description, original.description);
    });
  });
}
