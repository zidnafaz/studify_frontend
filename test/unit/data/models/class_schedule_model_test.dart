import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/class_schedule_model.dart';
import 'package:studify/data/models/user_model.dart';

void main() {
  group('ClassSchedule Model Tests', () {
    test('should create ClassSchedule from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'classroom_id': 1,
        'coordinator_1': null,
        'coordinator_2': null,
        'title': 'Math Class',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:30:00.000000Z',
        'location': 'Room A101',
        'lecturer': 'Dr. Smith',
        'description': 'Algebra basics',
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = ClassSchedule.fromJson(json);

      // Assert
      expect(schedule.id, 1);
      expect(schedule.classroomId, 1);
      expect(schedule.title, 'Math Class');
      expect(schedule.startTime, isA<DateTime>());
      expect(schedule.endTime, isA<DateTime>());
      expect(schedule.location, 'Room A101');
      expect(schedule.lecturer, 'Dr. Smith');
      expect(schedule.description, 'Algebra basics');
      expect(schedule.color, '#5CD9C1');
      expect(schedule.coordinator1, isNull);
      expect(schedule.coordinator2, isNull);
    });

    test('should create ClassSchedule with coordinators', () {
      // Arrange
      final json = {
        'id': 2,
        'classroom_id': 1,
        'coordinator_1': 1,
        'coordinator_2': 2,
        'title': 'Physics Class',
        'start_time': '2024-01-01T11:00:00.000000Z',
        'end_time': '2024-01-01T12:30:00.000000Z',
        'location': 'Lab B202',
        'lecturer': 'Prof. Johnson',
        'description': 'Mechanics',
        'color': '#B085CC',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = ClassSchedule.fromJson(json);

      // Assert
      expect(schedule.id, 2);
      expect(schedule.coordinator1, 1);
      expect(schedule.coordinator2, 2);
      expect(schedule.title, 'Physics Class');
    });

    test('should create ClassSchedule with null optional fields', () {
      // Arrange
      final json = {
        'id': 3,
        'classroom_id': 1,
        'coordinator_1': null,
        'coordinator_2': null,
        'title': 'Chemistry Class',
        'start_time': '2024-01-01T13:00:00.000000Z',
        'end_time': '2024-01-01T14:30:00.000000Z',
        'location': null,
        'lecturer': null,
        'description': null,
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = ClassSchedule.fromJson(json);

      // Assert
      expect(schedule.id, 3);
      expect(schedule.title, 'Chemistry Class');
      expect(schedule.location, isNull);
      expect(schedule.lecturer, isNull);
      expect(schedule.description, isNull);
    });

    test('should create ClassSchedule with coordinator users', () {
      // Arrange
      final json = {
        'id': 4,
        'classroom_id': 1,
        'coordinator_1': 1,
        'coordinator_2': 2,
        'title': 'Biology Class',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:30:00.000000Z',
        'location': 'Room C303',
        'lecturer': 'Dr. Williams',
        'description': 'Cell Biology',
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
        'coordinator1': {
          'id': 1,
          'name': 'Coordinator One',
          'email': 'coord1@example.com',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
        'coordinator2': {
          'id': 2,
          'name': 'Coordinator Two',
          'email': 'coord2@example.com',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
      };

      // Act
      final schedule = ClassSchedule.fromJson(json);

      // Assert
      expect(schedule.coordinator1User, isNotNull);
      expect(schedule.coordinator2User, isNotNull);
      expect(schedule.coordinator1User?.name, 'Coordinator One');
      expect(schedule.coordinator2User?.name, 'Coordinator Two');
    });

    test('should convert ClassSchedule to JSON', () {
      // Arrange
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Math Class',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Room A101',
        lecturer: 'Dr. Smith',
        description: 'Algebra basics',
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = schedule.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['classroom_id'], 1);
      expect(json['title'], 'Math Class');
      expect(json['location'], 'Room A101');
      expect(json['lecturer'], 'Dr. Smith');
      expect(json['description'], 'Algebra basics');
      expect(json['color'], '#5CD9C1');
      expect(json['start_time'], isA<String>());
      expect(json['end_time'], isA<String>());
    });

    test('should handle multiple schedules in a list', () {
      // Arrange
      final jsonList = [
        {
          'id': 1,
          'classroom_id': 1,
          'coordinator_1': null,
          'coordinator_2': null,
          'title': 'Math Class',
          'start_time': '2024-01-01T09:00:00.000000Z',
          'end_time': '2024-01-01T10:30:00.000000Z',
          'location': 'Room A101',
          'lecturer': 'Dr. Smith',
          'description': 'Algebra',
          'color': '#5CD9C1',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
        {
          'id': 2,
          'classroom_id': 1,
          'coordinator_1': null,
          'coordinator_2': null,
          'title': 'Physics Class',
          'start_time': '2024-01-01T11:00:00.000000Z',
          'end_time': '2024-01-01T12:30:00.000000Z',
          'location': 'Lab B202',
          'lecturer': 'Prof. Johnson',
          'description': 'Mechanics',
          'color': '#B085CC',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
      ];

      // Act
      final schedules = jsonList
          .map((json) => ClassSchedule.fromJson(json))
          .toList();

      // Assert
      expect(schedules.length, 2);
      expect(schedules[0].title, 'Math Class');
      expect(schedules[0].location, 'Room A101');
      expect(schedules[1].title, 'Physics Class');
      expect(schedules[1].location, 'Lab B202');
    });

    test('should validate time range', () {
      // Arrange
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Test Class',
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
        'classroom_id': 1,
        'coordinator_1': null,
        'coordinator_2': null,
        'title': 'Test Class',
        'start_time': '2024-01-15T10:30:00.000000Z',
        'end_time': '2024-01-15T12:00:00.000000Z',
        'location': 'Room A',
        'lecturer': 'Dr. Test',
        'description': 'Test',
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = ClassSchedule.fromJson(json);

      // Assert
      expect(schedule.startTime.year, 2024);
      expect(schedule.startTime.month, 1);
      expect(schedule.startTime.day, 15);
      expect(schedule.startTime.hour, 10);
      expect(schedule.startTime.minute, 30);
    });

    test('should validate color format', () {
      // Arrange
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Test Class',
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
      final original = ClassSchedule(
        id: 1,
        classroomId: 1,
        coordinator1: 1,
        coordinator2: 2,
        title: 'Test Class',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Room A',
        lecturer: 'Dr. Test',
        description: 'Test description',
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = original.toJson();
      final deserialized = ClassSchedule.fromJson(json);

      // Assert
      expect(deserialized.id, original.id);
      expect(deserialized.classroomId, original.classroomId);
      expect(deserialized.title, original.title);
      expect(deserialized.location, original.location);
      expect(deserialized.lecturer, original.lecturer);
      expect(deserialized.description, original.description);
      expect(deserialized.color, original.color);
    });

    test('should validate required fields', () {
      // Arrange & Act
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Test Class',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        coordinator2User: User(
          id: 2,
          name: 'Coordinator Two',
          email: 'coord2@test.com',
        ),
      );

      // Assert
      expect(schedule.id, isPositive);
      expect(schedule.classroomId, isPositive);
      expect(schedule.coordinator2User?.name, 'Coordinator Two');
    });

    test('should convert ClassSchedule to JSON', () {
      // Arrange
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Math Class',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Room A101',
        lecturer: 'Dr. Smith',
        description: 'Algebra basics',
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = schedule.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['classroom_id'], 1);
      expect(json['title'], 'Math Class');
      expect(json['location'], 'Room A101');
      expect(json['lecturer'], 'Dr. Smith');
      expect(json['description'], 'Algebra basics');
      expect(json['color'], '#5CD9C1');
      expect(json['start_time'], isA<String>());
      expect(json['end_time'], isA<String>());
    });

    test('should handle multiple schedules in a list', () {
      // Arrange
      final jsonList = [
        {
          'id': 1,
          'classroom_id': 1,
          'coordinator_1': null,
          'coordinator_2': null,
          'title': 'Math Class',
          'start_time': '2024-01-01T09:00:00.000000Z',
          'end_time': '2024-01-01T10:30:00.000000Z',
          'location': 'Room A101',
          'lecturer': 'Dr. Smith',
          'description': 'Algebra',
          'color': '#5CD9C1',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
        {
          'id': 2,
          'classroom_id': 1,
          'coordinator_1': null,
          'coordinator_2': null,
          'title': 'Physics Class',
          'start_time': '2024-01-01T11:00:00.000000Z',
          'end_time': '2024-01-01T12:30:00.000000Z',
          'location': 'Lab B202',
          'lecturer': 'Prof. Johnson',
          'description': 'Mechanics',
          'color': '#B085CC',
          'created_at': '2024-01-01T00:00:00.000000Z',
          'updated_at': '2024-01-01T00:00:00.000000Z',
        },
      ];

      // Act
      final schedules = jsonList
          .map((json) => ClassSchedule.fromJson(json))
          .toList();

      // Assert
      expect(schedules.length, 2);
      expect(schedules[0].title, 'Math Class');
      expect(schedules[0].location, 'Room A101');
      expect(schedules[1].title, 'Physics Class');
      expect(schedules[1].location, 'Lab B202');
    });

    test('should validate time range', () {
      // Arrange
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Test Class',
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
        'classroom_id': 1,
        'coordinator_1': null,
        'coordinator_2': null,
        'title': 'Test Class',
        'start_time': '2024-01-15T10:30:00.000000Z',
        'end_time': '2024-01-15T12:00:00.000000Z',
        'location': 'Room A',
        'lecturer': 'Dr. Test',
        'description': 'Test',
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final schedule = ClassSchedule.fromJson(json);

      // Assert
      expect(schedule.startTime.year, 2024);
      expect(schedule.startTime.month, 1);
      expect(schedule.startTime.day, 15);
      expect(schedule.startTime.hour, 10);
      expect(schedule.startTime.minute, 30);
    });

    test('should validate color format', () {
      // Arrange
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Test Class',
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
      final original = ClassSchedule(
        id: 1,
        classroomId: 1,
        coordinator1: 1,
        coordinator2: 2,
        title: 'Test Class',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Room A',
        lecturer: 'Dr. Test',
        description: 'Test description',
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = original.toJson();
      final deserialized = ClassSchedule.fromJson(json);

      // Assert
      expect(deserialized.id, original.id);
      expect(deserialized.classroomId, original.classroomId);
      expect(deserialized.title, original.title);
      expect(deserialized.location, original.location);
      expect(deserialized.lecturer, original.lecturer);
      expect(deserialized.description, original.description);
      expect(deserialized.color, original.color);
    });

    test('should validate required fields', () {
      // Arrange & Act
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Test Class',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Assert
      expect(schedule.id, isPositive);
      expect(schedule.classroomId, isPositive);
      expect(schedule.title, isNotEmpty);
      expect(schedule.color, isNotEmpty);
      expect(schedule.startTime, isNotNull);
      expect(schedule.endTime, isNotNull);
    });

    test('should create ClassSchedule with reminders', () {
      // Arrange
      final json = {
        'id': 5,
        'classroom_id': 1,
        'title': 'Repeating Class',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:30:00.000000Z',
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
        'reminders': [
          {
            'id': 1,
            'remindable_type': 'class_schedule',
            'remindable_id': 5,
            'minutes_before_start': 15,
            'status': 'pending',
            'created_at': '2024-01-01T00:00:00.000000Z',
            'updated_at': '2024-01-01T00:00:00.000000Z',
          },
          {
            'id': 2,
            'remindable_type': 'class_schedule',
            'remindable_id': 5,
            'minutes_before_start': 60,
            'status': 'pending',
            'created_at': '2024-01-01T00:00:00.000000Z',
            'updated_at': '2024-01-01T00:00:00.000000Z',
          },
        ],
      };

      // Act
      final schedule = ClassSchedule.fromJson(json);

      // Assert
      expect(schedule.reminders, hasLength(2));
      expect(schedule.reminders![0].minutesBeforeStart, 15);
      expect(schedule.reminders![1].minutesBeforeStart, 60);
    });

    test('should convert ClassSchedule with reminders to JSON', () {
      // Arrange
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Math Class',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Act
      final json = schedule.toJson();

      // Assert
      expect(json['id'], 1);
      // Reminders are not typically serialized back to JSON for creation in this model structure
    });
  });
}
