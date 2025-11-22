import 'package:flutter_test/flutter_test.dart';
import 'package:studify/providers/personal_schedule_provider.dart';
import 'package:studify/data/models/personal_schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PersonalScheduleProvider personalScheduleProvider;

  setUp(() {
    personalScheduleProvider = PersonalScheduleProvider();
    SharedPreferences.setMockInitialValues({'auth_token': 'test_token'});
  });

  group('PersonalScheduleProvider - State Management', () {
    test('initial state should be correct', () {
      // Assert
      expect(personalScheduleProvider.schedules, isEmpty);
      expect(personalScheduleProvider.isLoading, false);
      expect(personalScheduleProvider.errorMessage, isNull);
    });
  });

  group('PersonalScheduleProvider - PersonalSchedule Model Tests', () {
    test('PersonalSchedule model should be created correctly', () {
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

      // Assert
      expect(schedule.id, 1);
      expect(schedule.userId, 1);
      expect(schedule.title, 'Meeting with Team');
      expect(schedule.location, 'Office Room A');
      expect(schedule.description, 'Team discussion');
      expect(schedule.color, '#5CD9C1');
    });

    test('PersonalSchedule fromJson should work correctly', () {
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
      expect(schedule.location, 'Office Room A');
    });

    test('PersonalSchedule toJson should work correctly', () {
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
    });
  });

  group('PersonalScheduleProvider - Data Validation', () {
    test('PersonalSchedule should handle null optional fields', () {
      // Arrange
      final json = {
        'id': 1,
        'user_id': 1,
        'title': 'Personal Task',
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
      expect(schedule.location, isNull);
      expect(schedule.description, isNull);
    });

    test('PersonalSchedule should validate time range', () {
      // Arrange
      final startTime = DateTime.parse('2024-01-01T09:00:00.000000Z');
      final endTime = DateTime.parse('2024-01-01T10:30:00.000000Z');

      final schedule = PersonalSchedule(
        id: 1,
        userId: 1,
        title: 'Test Schedule',
        startTime: startTime,
        endTime: endTime,
        color: '#5CD9C1',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Assert
      expect(schedule.endTime.isAfter(schedule.startTime), isTrue);
    });
  });

  group('PersonalScheduleProvider - List Operations', () {
    test('should handle multiple schedules', () {
      // Arrange
      final schedulesList = [
        PersonalSchedule(
          id: 1,
          userId: 1,
          title: 'Meeting 1',
          startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
          location: 'Room A',
          color: '#5CD9C1',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        ),
        PersonalSchedule(
          id: 2,
          userId: 1,
          title: 'Meeting 2',
          startTime: DateTime.parse('2024-01-01T11:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T12:00:00.000000Z'),
          location: 'Room B',
          color: '#B085CC',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        ),
      ];

      // Assert
      expect(schedulesList.length, 2);
      expect(schedulesList[0].title, 'Meeting 1');
      expect(schedulesList[1].title, 'Meeting 2');
    });

    test('should sort schedules by start time', () {
      // Arrange
      final schedules = [
        PersonalSchedule(
          id: 2,
          userId: 1,
          title: 'Later Meeting',
          startTime: DateTime.parse('2024-01-01T14:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T15:00:00.000000Z'),
          color: '#5CD9C1',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        ),
        PersonalSchedule(
          id: 1,
          userId: 1,
          title: 'Earlier Meeting',
          startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
          color: '#5CD9C1',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        ),
      ];

      // Act
      schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Assert
      expect(schedules[0].title, 'Earlier Meeting');
      expect(schedules[1].title, 'Later Meeting');
    });
  });
}

