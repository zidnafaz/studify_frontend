import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studify/providers/notification_provider.dart';
import 'package:studify/data/models/notification_model.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late NotificationProvider provider;
  late MockNotificationService mockService;

  setUp(() {
    mockService = MockNotificationService();
    provider = NotificationProvider(service: mockService);
  });

  group('NotificationProvider Integration Tests', () {
    final testNotification = NotificationModel(
      id: 1,
      title: 'Test Notification',
      body: 'This is a test',
      isRead: false,
      createdAt: DateTime.now(),
    );

    test('fetchNotifications updates state correctly on success', () async {
      // Arrange
      when(mockService.fetchNotifications())
          .thenAnswer((_) async => [testNotification]);

      // Act
      await provider.fetchNotifications();

      // Assert
      expect(provider.notifications, contains(testNotification));
      expect(provider.unreadCount, 1);
      expect(provider.isLoading, false);
      verify(mockService.fetchNotifications()).called(1);
    });

    test('markAsRead updates notification status locally', () async {
      // Arrange
      when(mockService.fetchNotifications())
          .thenAnswer((_) async => [testNotification]);
      await provider.fetchNotifications();

      when(mockService.markAsRead(testNotification.id))
          .thenAnswer((_) async => {});

      // Act
      await provider.markAsRead(testNotification.id);

      // Assert
      expect(provider.notifications.first.isRead, true);
      expect(provider.unreadCount, 0);
      verify(mockService.markAsRead(testNotification.id)).called(1);
    });

    test('markAllRead updates all notifications locally', () async {
      // Arrange
      when(mockService.fetchNotifications())
          .thenAnswer((_) async => [testNotification]);
      await provider.fetchNotifications();

      when(mockService.markAllRead())
          .thenAnswer((_) async => {});

      // Act
      await provider.markAllRead();

      // Assert
      expect(provider.notifications.first.isRead, true);
      expect(provider.unreadCount, 0);
      verify(mockService.markAllRead()).called(1);
    });
  });
}
