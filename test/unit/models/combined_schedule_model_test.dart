import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/combined_schedule_model.dart';

void main() {
  group('CombinedSchedule Model Tests', () {
    test('should create CombinedSchedule for personal schedule from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'type': 'personal',
        'title': 'Personal Meeting',
        'start_time': '2024-01-01T09:00:00.000000Z',
        'end_time': '2024-01-01T10:30:00.000000Z',
        'location': 'Office Room A',
        'description': 'Personal meeting',
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
      expect(schedule.id, 1);
      expect(schedule.type, 'personal');
      expect(schedule.title, 'Personal Meeting');
      expect(schedule.startTime, isA<DateTime>());
      expect(schedule.endTime, isA<DateTime>());
      expect(schedule.location, 'Office Room A');
      expect(schedule.description, 'Personal meeting');
      expect(schedule.color, '#5CD9C1');
      expect(schedule.sourceId, isNull);
      expect(schedule.sourceName, 'Personal Schedule');
      expect(schedule.isPersonal, true);
      expect(schedule.isClass, false);
    });

    test('should create CombinedSchedule for class schedule from valid JSON', () {
      // Arrange
      final json = {
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
      };

      // Act
      final schedule = CombinedSchedule.fromJson(json);

      // Assert
      expect(schedule.id, 2);
      expect(schedule.type, 'class');
      expect(schedule.title, 'Math Class');
      expect(schedule.lecturer, 'Dr. Smith');
      expect(schedule.sourceId, 5);
      expect(schedule.sourceName, 'Classroom A');
      expect(schedule.coordinator1, 10);
      expect(schedule.coordinator2, 11);
      expect(schedule.coordinator1User, isNotNull);
      expect(schedule.coordinator2User, isNotNull);
      expect(schedule.isPersonal, false);
      expect(schedule.isClass, true);
    });

    test('should create CombinedSchedule with null optional fields', () {
      // Arrange
      final json = {
        'id': 3,
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
    });

    test('should convert CombinedSchedule to JSON', () {
      // Arrange
      final schedule = CombinedSchedule(
        id: 1,
        type: 'personal',
        title: 'Test Meeting',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Room A',
        description: 'Test description',
        color: '#5CD9C1',
        sourceId: null,
        sourceName: 'Personal Schedule',
      );

      // Act
      final json = schedule.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['type'], 'personal');
      expect(json['title'], 'Test Meeting');
      expect(json['location'], 'Room A');
      expect(json['description'], 'Test description');
      expect(json['color'], '#5CD9C1');
      expect(json['source_name'], 'Personal Schedule');
    });

    test('should handle DateTime parsing correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'type': 'personal',
        'title': 'Test Schedule',
        'start_time': '2024-01-15T10:30:00.000000Z',
        'end_time': '2024-01-15T12:00:00.000000Z',
        'location': 'Room A',
        'description': 'Test',
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
      expect(schedule.startTime.year, 2024);
      expect(schedule.startTime.month, 1);
      expect(schedule.startTime.day, 15);
      expect(schedule.startTime.hour, 10);
      expect(schedule.startTime.minute, 30);
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

    test('should handle roundtrip JSON serialization', () {
      // Arrange
      final original = CombinedSchedule(
        id: 1,
        type: 'personal',
        title: 'Test Schedule',
        startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
        endTime: DateTime.parse('2024-01-01T10:30:00.000000Z'),
        location: 'Room A',
        description: 'Test description',
        color: '#5CD9C1',
        sourceName: 'Personal Schedule',
      );

      // Act
      final json = original.toJson();
      final deserialized = CombinedSchedule.fromJson(json);

      // Assert
      expect(deserialized.id, original.id);
      expect(deserialized.type, original.type);
      expect(deserialized.title, original.title);
      expect(deserialized.location, original.location);
      expect(deserialized.description, original.description);
      expect(deserialized.color, original.color);
      expect(deserialized.sourceName, original.sourceName);
    });
  });

  group('ScheduleSource Model Tests', () {
    test('should create ScheduleSource for all type', () {
      // Arrange
      final json = {
        'id': 'all',
        'type': 'all',
        'name': 'All Schedules',
        'description': 'Show all schedules',
        'classroom_id': null,
      };

      // Act
      final source = ScheduleSource.fromJson(json);

      // Assert
      expect(source.id, 'all');
      expect(source.type, 'all');
      expect(source.name, 'All Schedules');
      expect(source.description, 'Show all schedules');
      expect(source.classroomId, isNull);
    });

    test('should create ScheduleSource for personal type', () {
      // Arrange
      final json = {
        'id': 'personal',
        'type': 'personal',
        'name': 'Personal Schedules',
        'description': 'Show personal schedules only',
        'classroom_id': null,
      };

      // Act
      final source = ScheduleSource.fromJson(json);

      // Assert
      expect(source.id, 'personal');
      expect(source.type, 'personal');
      expect(source.name, 'Personal Schedules');
      expect(source.classroomId, isNull);
    });

    test('should create ScheduleSource for classroom type', () {
      // Arrange
      final json = {
        'id': 'classroom:5',
        'type': 'classroom',
        'name': 'Classroom A',
        'description': 'Schedules from Classroom A',
        'classroom_id': 5,
      };

      // Act
      final source = ScheduleSource.fromJson(json);

      // Assert
      expect(source.id, 'classroom:5');
      expect(source.type, 'classroom');
      expect(source.name, 'Classroom A');
      expect(source.classroomId, 5);
    });

    test('should convert ScheduleSource to JSON', () {
      // Arrange
      final source = ScheduleSource(
        id: 'classroom:5',
        type: 'classroom',
        name: 'Classroom A',
        description: 'Schedules from Classroom A',
        classroomId: 5,
      );

      // Act
      final json = source.toJson();

      // Assert
      expect(json['id'], 'classroom:5');
      expect(json['type'], 'classroom');
      expect(json['name'], 'Classroom A');
      expect(json['classroom_id'], 5);
    });
  });

  group('CombinedScheduleResponse Model Tests', () {
    test('should create CombinedScheduleResponse from valid JSON', () {
      // Arrange
      final json = {
        'data': [
          {
            'id': 1,
            'type': 'personal',
            'title': 'Personal Meeting',
            'start_time': '2024-01-01T09:00:00.000000Z',
            'end_time': '2024-01-01T10:30:00.000000Z',
            'location': 'Room A',
            'description': 'Test',
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
          'current_filter': null,
        },
      };

      // Act
      final response = CombinedScheduleResponse.fromJson(json);

      // Assert
      expect(response.data.length, 1);
      expect(response.data[0].title, 'Personal Meeting');
      expect(response.meta.total, 1);
      expect(response.meta.availableSources.length, 2);
      expect(response.meta.currentFilter, isNull);
    });

    test('should create CombinedScheduleResponse with filter', () {
      // Arrange
      final json = {
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
          'current_filter': 'personal',
        },
      };

      // Act
      final response = CombinedScheduleResponse.fromJson(json);

      // Assert
      expect(response.data.length, 0);
      expect(response.meta.total, 0);
      expect(response.meta.currentFilter, 'personal');
    });

    test('should convert CombinedScheduleResponse to JSON', () {
      // Arrange
      final schedules = [
        CombinedSchedule(
          id: 1,
          type: 'personal',
          title: 'Test',
          startTime: DateTime.parse('2024-01-01T09:00:00.000000Z'),
          endTime: DateTime.parse('2024-01-01T10:00:00.000000Z'),
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

      // Act
      final json = response.toJson();

      // Assert
      expect(json['data'], isA<List>());
      expect(json['meta'], isNotNull);
      // Check if meta is a Map or has been serialized
      if (json['meta'] is Map) {
        expect(json['meta']['total'], 1);
      } else {
        // If meta is still an object, check its properties directly
        final metaObj = json['meta'] as CombinedScheduleMeta;
        expect(metaObj.total, 1);
      }
    });
  });
}

