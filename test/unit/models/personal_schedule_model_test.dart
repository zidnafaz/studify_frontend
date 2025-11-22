import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/personal_schedule_model.dart';

void main() {
  group('PersonalSchedule Model Tests', () {
    test('should create PersonalSchedule from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'user_id': 1,
        'title': 'Meeting with Team',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:30:00.000000Z',
        'location': 'Office Room A',
        'description': 'Team discussion',
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = PersonalSchedule.fromJson(json);

      // Assert
      expect(schedule.id, 1);
      expect(schedule.userId, 1);
      expect(schedule.title, 'Meeting with Team');
      expect(schedule.startTime, isA<DateTime>());
      expect(schedule.endTime, isA<DateTime>());
      expect(schedule.location, 'Office Room A');
      expect(schedule.description, 'Team discussion');
      expect(schedule.color, '#5CD9C1');
    });

    test('should create PersonalSchedule with null optional fields', () {
      // Arrange
      final json = {
        'id': 2,
        'user_id': 1,
        'title': 'Personal Task',
        'start_time': '2024-01-01T11:00:00.000000Z',
        'end_time': '2024-01-01T12:00:00.000000Z',
        'location': null,
        'description': null,
        'color': '#B085CC',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = PersonalSchedule.fromJson(json);

      // Assert
      expect(schedule.id, 2);
      expect(schedule.title, 'Personal Task');
      expect(schedule.location, isNull);
      expect(schedule.description, isNull);
      expect(schedule.color, '#B085CC');
    });

    test('should convert PersonalSchedule to JSON', () {
      // Arrange
      final schedule = PersonalSchedule(
        id: 1,
        userId: 1,
        title: 'Meeting with Team',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Office Room A',
        description: 'Team discussion',
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = schedule.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['user_id'], 1);
      expect(json['title'], 'Meeting with Team');
      expect(json['location'], 'Office Room A');
      expect(json['description'], 'Team discussion');
      expect(json['color'], '#5CD9C1');
      expect(json['start_time'], isA<String>());
      expect(json['end_time'], isA<String>());
    });

    test('should handle multiple schedules in a list', () {
      // Arrange
      final jsonList = [
        {
          'id': 1,
          'user_id': 1,
          'title': 'Meeting 1',
          'start_time': '2024-01-01T09:00:00.000000Z',
          'end_time': '2024-01-01T10:00:00.000000Z',
          'location': 'Room A',
          'description': 'First meeting',
          'color': '#5CD9C1',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
        {
          'id': 2,
          'user_id': 1,
          'title': 'Meeting 2',
          'start_time': '2024-01-01T11:00:00.000000Z',
          'end_time': '2024-01-01T12:00:00.000000Z',
          'location': 'Room B',
          'description': 'Second meeting',
          'color': '#B085CC',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
      ];

      // Act
      final schedules = jsonList.map((json) => PersonalSchedule.fromJson(json)).toList();

      // Assert
      expect(schedules.length, 2);
      expect(schedules[0].title, 'Meeting 1');
      expect(schedules[0].location, 'Room A');
      expect(schedules[1].title, 'Meeting 2');
      expect(schedules[1].location, 'Room B');
    });

    test('should validate time range', () {
      // Arrange
      final schedule = PersonalSchedule(
        id: 1,
        userId: 1,
        title: 'Test Schedule',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Assert
      expect(schedule.endTime.isAfter(schedule.startTime), isTrue);
      expect(schedule.endTime.difference(schedule.startTime).inMinutes, 90);
    });

    test('should handle DateTime parsing correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'user_id': 1,
        'title': 'Test Schedule',
        'start_time': '2024-01-15T10:30:00.000000Z',
        'end_time': '2024-01-15T12:00:00.000000Z',
        'location': 'Room A',
        'description': 'Test',
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = PersonalSchedule.fromJson(json);

      // Assert
      expect(schedule.startTime.year, 2024);
      expect(schedule.startTime.month, 1);
      expect(schedule.startTime.day, 15);
      expect(schedule.startTime.hour, 10);
      expect(schedule.startTime.minute, 30);
    });

    test('should validate color format', () {
      // Arrange
      final schedule = PersonalSchedule(
        id: 1,
        userId: 1,
        title: 'Test Schedule',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Assert
      expect(schedule.color, startsWith('#'));
      expect(schedule.color.length, 7);
    });

    test('should handle roundtrip JSON serialization', () {
      // Arrange
      final original = PersonalSchedule(
        id: 1,
        userId: 1,
        title: 'Test Schedule',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Room A',
        description: 'Test description',
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = original.toJson();
      final deserialized = PersonalSchedule.fromJson(json);

      // Assert
      expect(deserialized.id, original.id);
      expect(deserialized.userId, original.userId);
      expect(deserialized.title, original.title);
      expect(deserialized.location, original.location);
      expect(deserialized.description, original.description);
      expect(deserialized.color, original.color);
    });

    test('should validate required fields', () {
      // Arrange & Act
      final schedule = PersonalSchedule(
        id: 1,
        userId: 1,
        title: 'Test Schedule',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Assert
      expect(schedule.id, isPositive);
      expect(schedule.userId, isPositive);
      expect(schedule.title, isNotEmpty);
      expect(schedule.color, isNotEmpty);
      expect(schedule.startTime, isNotNull);
      expect(schedule.endTime, isNotNull);
    });

    test('should handle numeric ID conversion', () {
      // Arrange
      final json = {
        'id': 1.0, // Double instead of int
        'user_id': 1.0, // Double instead of int
        'title': 'Test Schedule',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:30:00.000000Z',
        'location': null,
        'description': null,
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = PersonalSchedule.fromJson(json);

      // Assert
      expect(schedule.id, 1);
      expect(schedule.userId, 1);
      expect(schedule.id, isA<int>());
      expect(schedule.userId, isA<int>());
    });
  });
}

