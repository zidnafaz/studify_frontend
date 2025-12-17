import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:studify/core/http/dio_client.dart';
import 'package:studify/data/services/class_schedule_service.dart';
import 'package:studify/data/models/class_schedule_model.dart';
import 'package:dio/dio.dart';
import 'package:studify/core/errors/api_exception.dart';

import 'class_schedule_service_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late ClassScheduleService service;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    service = ClassScheduleService(client: mockDioClient);
  });

  group('ClassScheduleService', () {
    group('getClassSchedules', () {
      test('should return list of class schedules on success', () async {
        // Arrange
        final classroomId = 1;
        final mockResponse = {
          'data': [
            {
              'id': 1,
              'classroom_id': classroomId,
              'title': 'Math Class',
              'start_time': '2024-12-17T10:00:00Z',
              'end_time': '2024-12-17T11:30:00Z',
              'color': '#FFFFFF',
              'created_at': '2024-12-17T10:00:00Z',
              'updated_at': '2024-12-17T10:00:00Z',
            },
          ],
        };

        when(mockDioClient.get('/api/classrooms/$classroomId/schedules'))
            .thenAnswer((_) async => Response(
                  data: mockResponse,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        // Act
        final result = await service.getClassSchedules(classroomId);

        // Assert
        expect(result, isA<List<ClassSchedule>>());
        expect(result.length, 1);
        expect(result.first.title, 'Math Class');
        verify(mockDioClient.get('/api/classrooms/$classroomId/schedules'))
            .called(1);
      });

      test('should throw exception on error', () async {
        // Arrange
        final classroomId = 1;
        when(mockDioClient.get('/api/classrooms/$classroomId/schedules'))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ));

        // Act & Assert
        expect(
          () => service.getClassSchedules(classroomId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('createClassSchedule', () {
      test('should create class schedule successfully', () async {
        // Arrange
        final classroomId = 1;
        final scheduleData = {
          'title': 'New Class',
          'start_time': '2024-12-18T10:00:00Z',
          'end_time': '2024-12-18T11:30:00Z',
        };

        final mockResponse = {
          'data': {
            'id': 2,
            'classroom_id': classroomId,
            ...scheduleData,
            'color': '#FFFFFF',
            'created_at': '2024-12-18T10:00:00Z',
            'updated_at': '2024-12-18T10:00:00Z',
          },
        };

        when(mockDioClient.post(
          '/api/classrooms/$classroomId/schedules',
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: mockResponse,
              statusCode: 201,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await service.createClassSchedule(
          classroomId,
          scheduleData,
        );

        // Assert
        expect(result, isA<ClassSchedule>());
        expect(result.title, 'New Class');
        verify(mockDioClient.post(
          '/api/classrooms/$classroomId/schedules',
          data: anyNamed('data'),
        )).called(1);
      });
    });

    group('updateClassSchedule', () {
      test('should update class schedule successfully', () async {
        // Arrange
        final classroomId = 1;
        final scheduleId = 2;
        final updateData = {'title': 'Updated Class'};

        final mockResponse = {
          'data': {
            'id': scheduleId,
            'classroom_id': classroomId,
            'title': 'Updated Class',
            'start_time': '2024-12-17T10:00:00Z',
            'end_time': '2024-12-17T11:30:00Z',
            'color': '#FFFFFF',
            'created_at': '2024-12-17T10:00:00Z',
            'updated_at': '2024-12-17T10:00:00Z',
          },
        };

        when(mockDioClient.put(
          '/api/classrooms/$classroomId/schedules/$scheduleId',
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: mockResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await service.updateClassSchedule(
          classroomId,
          scheduleId,
          updateData,
        );

        // Assert
        expect(result.title, 'Updated Class');
      });
    });

    group('deleteClassSchedule', () {
      test('should delete class schedule successfully', () async {
        // Arrange
        final classroomId = 1;
        final scheduleId = 2;

        when(mockDioClient.delete(
          '/api/classrooms/$classroomId/schedules/$scheduleId',
        )).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        await service.deleteClassSchedule(classroomId, scheduleId);

        // Assert
        verify(mockDioClient.delete(
          '/api/classrooms/$classroomId/schedules/$scheduleId',
        )).called(1);
      });
    });
  });
}
