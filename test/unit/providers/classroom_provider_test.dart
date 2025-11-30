import 'package:flutter_test/flutter_test.dart';
import 'package:studify/providers/classroom_provider.dart';
import 'package:studify/data/models/classroom_model.dart';
import 'package:studify/data/models/class_schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ClassroomProvider classroomProvider;

  setUp(() {
    classroomProvider = ClassroomProvider();
    SharedPreferences.setMockInitialValues({'auth_token': 'test_token'});
  });

  group('ClassroomProvider - State Management', () {
    test('initial state should be correct', () {
      // Assert
      expect(classroomProvider.classrooms, isEmpty);
      expect(classroomProvider.selectedClassroom, isNull);
      expect(classroomProvider.schedules, isEmpty);
      expect(classroomProvider.isLoading, false);
      expect(classroomProvider.errorMessage, isNull);
    });

    test('clearError should clear error message', () {
      // Arrange
      classroomProvider.clearError();

      // Assert
      expect(classroomProvider.errorMessage, isNull);
    });

    test('clearSchedules should clear schedules list', () {
      // Act
      classroomProvider.clearSchedules();

      // Assert
      expect(classroomProvider.schedules, isEmpty);
    });
  });

  group('ClassroomProvider - Classroom Model Tests', () {
    test('Classroom model should be created correctly', () {
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

      // Assert
      expect(classroom.id, 1);
      expect(classroom.name, 'Test Classroom');
      expect(classroom.uniqueCode, 'ABC123');
      expect(classroom.description, 'Test description');
    });

    test('Classroom fromJson should work correctly', () {
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
      expect(classroom.name, 'Test Classroom');
      expect(classroom.uniqueCode, 'ABC123');
    });

    test('Classroom toJson should work correctly', () {
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
      expect(json['name'], 'Test Classroom');
      expect(json['unique_code'], 'ABC123');
    });
  });

  group('ClassroomProvider - ClassSchedule Model Tests', () {
    test('ClassSchedule model should be created correctly', () {
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

      // Assert
      expect(schedule.id, 1);
      expect(schedule.title, 'Math Class');
      expect(schedule.location, 'Room A101');
      expect(schedule.lecturer, 'Dr. Smith');
      expect(schedule.color, '#5CD9C1');
    });

    test('ClassSchedule fromJson should work correctly', () {
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
      expect(schedule.title, 'Math Class');
      expect(schedule.location, 'Room A101');
    });

    test('ClassSchedule toJson should work correctly', () {
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
    });

    test('ClassSchedule with coordinators should work correctly', () {
      // Arrange
      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        coordinator1: 1,
        coordinator2: 2,
        title: 'Physics Class',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        color: '#B085CC',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
      );

      // Assert
      expect(schedule.coordinator1, 1);
      expect(schedule.coordinator2, 2);
    });

    test('ClassSchedule with reminders should work correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'classroom_id': 1,
        'title': 'Math Class',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:30:00.000000Z',
        'color': '#5CD9C1',
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
        'reminders': [
          {
            'id': 1,
            'remindable_type': 'class_schedule',
            'remindable_id': 1,
            'minutes_before_start': 15,
            'status': 'pending',
            'created_at': '2024-01-01T00:00:00.000000Z',
            'updated_at': '2024-01-01T00:00:00.000000Z',
          },
        ],
      };

      // Act
      final schedule = ClassSchedule.fromJson(json);

      // Assert
      expect(schedule.reminders, hasLength(1));
      expect(schedule.reminders![0].minutesBeforeStart, 15);
    });
  });

  group('ClassroomProvider - Data Validation', () {
    test('Classroom should handle null description', () {
      // Arrange
      final json = {
        'id': 1,
        'owner_id': 1,
        'name': 'Test Classroom',
        'unique_code': 'ABC123',
        'description': null,
        'created_at': '2024-01-01T00:00:00.000000Z',
        'updated_at': '2024-01-01T00:00:00.000000Z',
      };

      // Act
      final classroom = Classroom.fromJson(json);

      // Assert
      expect(classroom.description, isNull);
    });

    test('ClassSchedule should handle null optional fields', () {
      // Arrange
      final json = {
        'id': 1,
        'classroom_id': 1,
        'coordinator_1': null,
        'coordinator_2': null,
        'title': 'Test Class',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:30:00.000000Z',
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
      expect(schedule.location, isNull);
      expect(schedule.lecturer, isNull);
      expect(schedule.description, isNull);
      expect(schedule.coordinator1, isNull);
      expect(schedule.coordinator2, isNull);
    });

    test('ClassSchedule should validate time range', () {
      // Arrange
      final startTime = DateTime.parse('2024-01-01T09:00:00.000000Z');
      final endTime = DateTime.parse('2024-01-01T10:30:00.000000Z');

      final schedule = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Test Class',
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

  group('ClassroomProvider - List Operations', () {
    test('should handle multiple classrooms', () {
      // Arrange
      final classroomsList = [
        Classroom(
          id: 1,
          ownerId: 1,
          name: 'Classroom 1',
          uniqueCode: 'ABC123',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        ),
        Classroom(
          id: 2,
          ownerId: 1,
          name: 'Classroom 2',
          uniqueCode: 'DEF456',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        ),
      ];

      // Assert
      expect(classroomsList.length, 2);
      expect(classroomsList[0].name, 'Classroom 1');
      expect(classroomsList[1].name, 'Classroom 2');
    });

    test('should handle multiple schedules', () {
      // Arrange
      final schedulesList = [
        ClassSchedule(
          id: 1,
          classroomId: 1,
          title: 'Math Class',
          startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
          color: '#5CD9C1',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        ),
        ClassSchedule(
          id: 2,
          classroomId: 1,
          title: 'Physics Class',
          startTime: DateTime.parse('2024-01-01T11:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T12:30:00.000000Z'),
          color: '#B085CC',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000000Z'),
        ),
      ];

      // Assert
      expect(schedulesList.length, 2);
      expect(schedulesList[0].title, 'Math Class');
      expect(schedulesList[1].title, 'Physics Class');
    });
  });
}
