import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:studify/data/services/notification_service.dart';
import 'package:studify/data/models/notification_model.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late NotificationService notificationService;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    notificationService = NotificationService(dioClient: mockDioClient);
  });

  group('NotificationService', () {
    final testDate = DateTime(2023, 1, 1, 12, 0, 0);
    final testNotificationJson = {
      'id': 1,
      'title': 'Test Notification',
      'body': 'This is a test body',
      'data': {'key': 'value'},
      'is_read': 0,
      'created_at': testDate.toIso8601String(),
    };

    test('fetchNotifications returns list of notifications on success', () async {
      // Arrange
      when(mockDioClient.get('/api/notifications')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/notifications'),
          data: {
            'data': [testNotificationJson]
          },
          statusCode: 200,
        ),
      );

      // Act
      final result = await notificationService.fetchNotifications();

      // Assert
      expect(result, isA<List<NotificationModel>>());
      expect(result.length, 1);
      expect(result.first.id, 1);
      verify(mockDioClient.get('/api/notifications')).called(1);
    });

    test('fetchNotifications throws exception on error', () async {
      // Arrange
      when(mockDioClient.get('/api/notifications')).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(notificationService.fetchNotifications(), throwsException);
    });

    test('markAsRead calls correct API endpoint', () async {
      // Arrange
      when(mockDioClient.patch('/api/notifications/1/read')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/notifications/1/read'),
          statusCode: 200,
        ),
      );

      // Act
      await notificationService.markAsRead(1);

      // Assert
      verify(mockDioClient.patch('/api/notifications/1/read')).called(1);
    });

    test('markAllRead calls correct API endpoint', () async {
      // Arrange
      when(mockDioClient.patch('/api/notifications/read-all')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/notifications/read-all'),
          statusCode: 200,
        ),
      );

      // Act
      await notificationService.markAllRead();

      // Assert
      verify(mockDioClient.patch('/api/notifications/read-all')).called(1);
    });
  });
}
