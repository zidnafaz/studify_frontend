import 'package:flutter_test/flutter_test.dart';
import 'package:studify/providers/combined_schedule_provider.dart';
import 'package:studify/data/models/combined_schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CombinedScheduleProvider combinedScheduleProvider;

  setUp(() {
    combinedScheduleProvider = CombinedScheduleProvider();
    SharedPreferences.setMockInitialValues({'auth_token': 'test_token'});
  });

  group('CombinedScheduleProvider - State Management', () {
    test('initial state should be correct', () {
      // Assert
      expect(combinedScheduleProvider.schedules, isEmpty);
      expect(combinedScheduleProvider.availableSources, isEmpty);
      expect(combinedScheduleProvider.currentFilter, isNull);
      expect(combinedScheduleProvider.isLoading, false);
      expect(combinedScheduleProvider.errorMessage, isNull);
    });

    test('schedules should be unmodifiable', () {
      // Arrange
      final schedules = combinedScheduleProvider.schedules;

      // Assert
      expect(() => schedules.add(CombinedSchedule(
            id: 1,
            type: 'personal',
            title: 'Test',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            color: '#5CD9C1',
            sourceName: 'Personal Schedule',
          )), throwsA(isA<UnsupportedError>()));
    });

    test('availableSources should be unmodifiable', () {
      // Arrange
      final sources = combinedScheduleProvider.availableSources;

      // Assert
      expect(() => sources.add(ScheduleSource(
            id: 'all',
            type: 'all',
            name: 'All',
            description: 'All schedules',
          )), throwsA(isA<UnsupportedError>()));
    });
  });

  group('CombinedScheduleProvider - Data Operations', () {
    test('clear should reset all state', () {
      // Act
      combinedScheduleProvider.clear();

      // Assert
      expect(combinedScheduleProvider.schedules, isEmpty);
      expect(combinedScheduleProvider.availableSources, isEmpty);
      expect(combinedScheduleProvider.currentFilter, isNull);
      expect(combinedScheduleProvider.errorMessage, isNull);
    });

    test('should handle CombinedSchedule model correctly', () {
      // Arrange
      final schedule = CombinedSchedule(
        id: 1,
        type: 'personal',
        title: 'Personal Meeting',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Room A',
        description: 'Personal meeting',
        color: '#5CD9C1',
        sourceId: null,
        sourceName: 'Personal Schedule',
      );

      // Assert
      expect(schedule.id, 1);
      expect(schedule.type, 'personal');
      expect(schedule.title, 'Personal Meeting');
      expect(schedule.isPersonal, true);
      expect(schedule.isClass, false);
    });

    test('should handle class schedule model correctly', () {
      // Arrange
      final schedule = CombinedSchedule(
        id: 2,
        type: 'class',
        title: 'Math Class',
        startTime: DateTime.parse('2024-01-01T11:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T12:30:00.000000Z'),
        location: 'Room 101',
        description: 'Mathematics lecture',
        color: '#B085CC',
        sourceId: 5,
        sourceName: 'Classroom A',
        lecturer: 'Dr. Smith',
        coordinator1: 10,
        coordinator2: 11,
      );

      // Assert
      expect(schedule.id, 2);
      expect(schedule.type, 'class');
      expect(schedule.title, 'Math Class');
      expect(schedule.lecturer, 'Dr. Smith');
      expect(schedule.sourceId, 5);
      expect(schedule.isPersonal, false);
      expect(schedule.isClass, true);
    });

    test('should handle ScheduleSource model correctly', () {
      // Arrange
      final source = ScheduleSource(
        id: 'classroom:5',
        type: 'classroom',
        name: 'Classroom A',
        description: 'Schedules from Classroom A',
        classroomId: 5,
      );

      // Assert
      expect(source.id, 'classroom:5');
      expect(source.type, 'classroom');
      expect(source.name, 'Classroom A');
      expect(source.classroomId, 5);
    });

    test('should handle CombinedScheduleResponse model correctly', () {
      // Arrange
      final schedules = [
        CombinedSchedule(
          id: 1,
          type: 'personal',
          title: 'Personal Meeting',
          startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
          color: '#5CD9C1',
          sourceName: 'Personal Schedule',
        ),
      ];
      final sources = [
        ScheduleSource(
          id: 'all',
          type: 'all',
          name: 'All Schedules',
          description: 'Show all schedules',
        ),
        ScheduleSource(
          id: 'personal',
          type: 'personal',
          name: 'Personal Schedules',
          description: 'Show personal schedules only',
        ),
      ];
      final meta = CombinedScheduleMeta(
        total: 1,
        availableSources: sources,
        currentFilter: null,
      );
      final response = CombinedScheduleResponse(
        data: schedules,
        meta: meta,
      );

      // Assert
      expect(response.data.length, 1);
      expect(response.meta.total, 1);
      expect(response.meta.availableSources.length, 2);
      expect(response.meta.currentFilter, isNull);
    });
  });

  group('CombinedScheduleProvider - Filter Operations', () {
    test('should handle null filter (all schedules)', () {
      // Arrange
      final response = CombinedScheduleResponse(
        data: [
          CombinedSchedule(
            id: 1,
            type: 'personal',
            title: 'Personal',
            startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
            endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
            color: '#5CD9C1',
            sourceName: 'Personal Schedule',
          ),
          CombinedSchedule(
            id: 2,
            type: 'class',
            title: 'Class',
            startTime: DateTime.parse('2024-01-01T11:00:00.000000Z'),
            endTime: DateTime.parse('2024-01-01T12:00:00.000000Z'),
            color: '#B085CC',
            sourceId: 5,
            sourceName: 'Classroom A',
          ),
        ],
        meta: CombinedScheduleMeta(
          total: 2,
          availableSources: [],
          currentFilter: null,
        ),
      );

      // Assert
      expect(response.data.length, 2);
      expect(response.meta.currentFilter, isNull);
    });

    test('should handle personal filter', () {
      // Arrange
      final response = CombinedScheduleResponse(
        data: [
          CombinedSchedule(
            id: 1,
            type: 'personal',
            title: 'Personal',
            startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
            endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
            color: '#5CD9C1',
            sourceName: 'Personal Schedule',
          ),
        ],
        meta: CombinedScheduleMeta(
          total: 1,
          availableSources: [],
          currentFilter: 'personal',
        ),
      );

      // Assert
      expect(response.data.length, 1);
      expect(response.data[0].type, 'personal');
      expect(response.meta.currentFilter, 'personal');
    });

    test('should handle classroom filter', () {
      // Arrange
      final response = CombinedScheduleResponse(
        data: [
          CombinedSchedule(
            id: 2,
            type: 'class',
            title: 'Class',
            startTime: DateTime.parse('2024-01-01T11:00:00.000000Z'),
            endTime: DateTime.parse('2024-01-01T12:00:00.000000Z'),
            color: '#B085CC',
            sourceId: 5,
            sourceName: 'Classroom A',
          ),
        ],
        meta: CombinedScheduleMeta(
          total: 1,
          availableSources: [],
          currentFilter: 'classroom:5',
        ),
      );

      // Assert
      expect(response.data.length, 1);
      expect(response.data[0].type, 'class');
      expect(response.data[0].sourceId, 5);
      expect(response.meta.currentFilter, 'classroom:5');
    });
  });

  group('CombinedScheduleProvider - Data Validation', () {
    test('should validate schedule type', () {
      // Arrange
      final personalSchedule = CombinedSchedule(
        id: 1,
        type: 'personal',
        title: 'Personal',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
        color: '#5CD9C1',
        sourceName: 'Personal Schedule',
      );

      final classSchedule = CombinedSchedule(
        id: 2,
        type: 'class',
        title: 'Class',
        startTime: DateTime.parse('2024-01-01T11:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T12:00:00.000000Z'),
        color: '#B085CC',
        sourceId: 5,
        sourceName: 'Classroom A',
      );

      // Assert
      expect(personalSchedule.isPersonal, true);
      expect(personalSchedule.isClass, false);
      expect(classSchedule.isPersonal, false);
      expect(classSchedule.isClass, true);
    });

    test('should validate time range', () {
      // Arrange
      final schedule = CombinedSchedule(
        id: 1,
        type: 'personal',
        title: 'Test Schedule',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        color: '#5CD9C1',
        sourceName: 'Personal Schedule',
      );

      // Assert
      expect(schedule.endTime.isAfter(schedule.startTime), isTrue);
      expect(schedule.endTime.difference(schedule.startTime).inMinutes, 90);
    });

    test('should handle null optional fields', () {
      // Arrange
      final schedule = CombinedSchedule(
        id: 1,
        type: 'personal',
        title: 'Minimal Schedule',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
        color: '#5CD9C1',
        sourceName: 'Personal Schedule',
      );

      // Assert
      expect(schedule.location, isNull);
      expect(schedule.description, isNull);
      expect(schedule.lecturer, isNull);
      expect(schedule.sourceId, isNull);
    });
  });

  group('CombinedScheduleProvider - List Operations', () {
    test('should handle multiple schedules', () {
      // Arrange
      final schedulesList = [
        CombinedSchedule(
          id: 1,
          type: 'personal',
          title: 'Personal Meeting',
          startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
          color: '#5CD9C1',
          sourceName: 'Personal Schedule',
        ),
        CombinedSchedule(
          id: 2,
          type: 'class',
          title: 'Math Class',
          startTime: DateTime.parse('2024-01-01T11:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T12:00:00.000000Z'),
          color: '#B085CC',
          sourceId: 5,
          sourceName: 'Classroom A',
        ),
      ];

      // Assert
      expect(schedulesList.length, 2);
      expect(schedulesList[0].title, 'Personal Meeting');
      expect(schedulesList[1].title, 'Math Class');
    });

    test('should sort schedules by start time', () {
      // Arrange
      final schedules = [
        CombinedSchedule(
          id: 2,
          type: 'personal',
          title: 'Later Meeting',
          startTime: DateTime.parse('2024-01-01T14:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T15:00:00.000000Z'),
          color: '#5CD9C1',
          sourceName: 'Personal Schedule',
        ),
        CombinedSchedule(
          id: 1,
          type: 'personal',
          title: 'Earlier Meeting',
          startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
          color: '#5CD9C1',
          sourceName: 'Personal Schedule',
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

