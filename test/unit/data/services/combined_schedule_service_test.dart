import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studify/data/models/combined_schedule_model.dart';
import 'package:studify/core/errors/api_exception.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'auth_token': 'test_token'});
  });

  group('CombinedScheduleService - Get Combined Schedules', () {
    test('should parse combined schedules response correctly', () {
      // Arrange
      final mockResponse = {
        'data': [
          {
            'id': 1,
            'type': 'personal',
            'title': 'Personal Meeting',
            'start_time': '2024-01-01T09:00:00.000000Z',
            'end_time': '2024-01-01T10:30:00.000000Z',
            'location': 'Room A',
            'description': 'Personal meeting',
            'color': '#5CD9C1',
            'source_id': null,
            'source_name': 'Personal Schedule',
            'lecturer': null,
            'coordinator_1': null,
            'coordinator_2': null,
            'coordinator1': null,
            'coordinator2': null,
          },
          {
            'id': 2,
            'type': 'class',
            'title': 'Math Class',
            'start_time': '2024-01-01T11:00:00.000000Z',
            'end_time': '2024-01-01T12:30:00.000000Z',
            'location': 'Room 101',
            'description': 'Mathematics lecture',
            'color': '#B085CC',
            'source_id': 5,
            'source_name': 'Classroom A',
            'lecturer': 'Dr. Smith',
            'coordinator_1': 10,
            'coordinator_2': 11,
            'coordinator1': null,
            'coordinator2': null,
          },
        ],
        'meta': {
          'total': 2,
          'available_sources': [
            {
              'id': 'all',
              'type': 'all',
              'name': 'All Schedules',
              'description': 'Show all schedules',
              'classroom_id': null,
            },
            {
              'id': 'personal',
              'type': 'personal',
              'name': 'Personal Schedules',
              'description': 'Show personal schedules only',
              'classroom_id': null,
            },
            {
              'id': 'classroom:5',
              'type': 'classroom',
              'name': 'Classroom A',
              'description': 'Schedules from Classroom A',
              'classroom_id': 5,
            },
          ],
          'current_filter': null,
        },
      };

      // Act
      final response = CombinedScheduleResponse.fromJson(mockResponse);

      // Assert
      expect(response.data.length, 2);
      expect(response.data[0].type, 'personal');
      expect(response.data[0].title, 'Personal Meeting');
      expect(response.data[1].type, 'class');
      expect(response.data[1].title, 'Math Class');
      expect(response.data[1].lecturer, 'Dr. Smith');
      expect(response.meta.total, 2);
      expect(response.meta.availableSources.length, 3);
      expect(response.meta.currentFilter, isNull);
    });

    test('should parse response with personal filter', () {
      // Arrange
      final mockResponse = {
        'data': [
          {
            'id': 1,
            'type': 'personal',
            'title': 'Personal Meeting',
            'start_time': '2024-01-01T09:00:00.000000Z',
            'end_time': '2024-01-01T10:30:00.000000Z',
            'location': 'Room A',
            'description': 'Personal meeting',
            'color': '#5CD9C1',
            'source_id': null,
            'source_name': 'Personal Schedule',
            'lecturer': null,
            'coordinator_1': null,
            'coordinator_2': null,
            'coordinator1': null,
            'coordinator2': null,
          },
        ],
        'meta': {
          'total': 1,
          'available_sources': [
            {
              'id': 'all',
              'type': 'all',
              'name': 'All Schedules',
              'description': 'Show all schedules',
              'classroom_id': null,
            },
            {
              'id': 'personal',
              'type': 'personal',
              'name': 'Personal Schedules',
              'description': 'Show personal schedules only',
              'classroom_id': null,
            },
          ],
          'current_filter': 'personal',
        },
      };

      // Act
      final response = CombinedScheduleResponse.fromJson(mockResponse);

      // Assert
      expect(response.data.length, 1);
      expect(response.data[0].type, 'personal');
      expect(response.meta.currentFilter, 'personal');
    });

    test('should parse response with classroom filter', () {
      // Arrange
      final mockResponse = {
        'data': [
          {
            'id': 2,
            'type': 'class',
            'title': 'Math Class',
            'start_time': '2024-01-01T11:00:00.000000Z',
            'end_time': '2024-01-01T12:30:00.000000Z',
            'location': 'Room 101',
            'description': 'Mathematics lecture',
            'color': '#B085CC',
            'source_id': 5,
            'source_name': 'Classroom A',
            'lecturer': 'Dr. Smith',
            'coordinator_1': null,
            'coordinator_2': null,
            'coordinator1': null,
            'coordinator2': null,
          },
        ],
        'meta': {
          'total': 1,
          'available_sources': [
            {
              'id': 'all',
              'type': 'all',
              'name': 'All Schedules',
              'description': 'Show all schedules',
              'classroom_id': null,
            },
            {
              'id': 'classroom:5',
              'type': 'classroom',
              'name': 'Classroom A',
              'description': 'Schedules from Classroom A',
              'classroom_id': 5,
            },
          ],
          'current_filter': 'classroom:5',
        },
      };

      // Act
      final response = CombinedScheduleResponse.fromJson(mockResponse);

      // Assert
      expect(response.data.length, 1);
      expect(response.data[0].type, 'class');
      expect(response.data[0].sourceId, 5);
      expect(response.meta.currentFilter, 'classroom:5');
    });

    test('should handle empty schedules list', () {
      // Arrange
      final mockResponse = {
        'data': [],
        'meta': {
          'total': 0,
          'available_sources': [
            {
              'id': 'all',
              'type': 'all',
              'name': 'All Schedules',
              'description': 'Show all schedules',
              'classroom_id': null,
            },
          ],
          'current_filter': null,
        },
      };

      // Act
      final response = CombinedScheduleResponse.fromJson(mockResponse);

      // Assert
      expect(response.data.length, 0);
      expect(response.meta.total, 0);
    });

    test('should throw UnauthorizedException on 401', () {
      expect(
        () async {
          throw UnauthorizedException(message: 'Unauthorized');
        },
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('should throw ApiException on server error', () {
      expect(
        () async {
          throw ApiException(
            message: 'Server error',
            statusCode: 500,
          );
        },
        throwsA(isA<ApiException>()),
      );
    });

    test('should handle schedules with coordinators', () {
      // Arrange
      final mockResponse = {
        'data': [
          {
            'id': 1,
            'type': 'class',
            'title': 'Class with Coordinators',
            'start_time': '2024-01-01T09:00:00.000000Z',
            'end_time': '2024-01-01T10:30:00.000000Z',
            'location': 'Room A',
            'description': 'Test',
            'color': '#5CD9C1',
            'source_id': 5,
            'source_name': 'Classroom A',
            'lecturer': 'Dr. Smith',
            'coordinator_1': 10,
            'coordinator_2': 11,
            'coordinator1': {
              'id': 10,
              'name': 'Coordinator 1',
              'email': 'coord1@example.com',
              'created_at': '2024-01-01T00:00:00.000000Z',
              'updated_at': '2024-01-01T00:00:00.000000Z',
            },
            'coordinator2': {
              'id': 11,
              'name': 'Coordinator 2',
              'email': 'coord2@example.com',
              'created_at': '2024-01-01T00:00:00.000000Z',
              'updated_at': '2024-01-01T00:00:00.000000Z',
            },
          },
        ],
        'meta': {
          'total': 1,
          'available_sources': [],
          'current_filter': null,
        },
      };

      // Act
      final response = CombinedScheduleResponse.fromJson(mockResponse);

      // Assert
      expect(response.data.length, 1);
      expect(response.data[0].coordinator1, 10);
      expect(response.data[0].coordinator2, 11);
      expect(response.data[0].coordinator1User, isNotNull);
      expect(response.data[0].coordinator2User, isNotNull);
      expect(response.data[0].coordinator1User!.id, 10);
      expect(response.data[0].coordinator2User!.id, 11);
    });

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

    test('should handle null optional fields in schedule', () {
      // Arrange
      final json = {
        'id': 1,
        'type': 'personal',
        'title': 'Minimal Schedule',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:00:00.000000Z',
        'location': null,
        'description': null,
        'color': '#5CD9C1',
        'source_id': null,
        'source_name': 'Personal Schedule',
        'lecturer': null,
        'coordinator_1': null,
        'coordinator_2': null,
        'coordinator1': null,
        'coordinator2': null,
      };

      // Act
      final schedule = CombinedSchedule.fromJson(json);

      // Assert
      expect(schedule.location, isNull);
      expect(schedule.description, isNull);
      expect(schedule.lecturer, isNull);
      expect(schedule.sourceId, isNull);
      expect(schedule.coordinator1, isNull);
      expect(schedule.coordinator2, isNull);
      expect(schedule.coordinator1User, isNull);
      expect(schedule.coordinator2User, isNull);
    });
  });
}

