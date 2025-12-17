import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    final testDate = DateTime(2023, 1, 1, 12, 0, 0);
    final testJson = {
      'id': 1,
      'title': 'Test Notification',
      'body': 'This is a test body',
      'data': {'key': 'value'},
      'is_read': 0,
      'created_at': testDate.toIso8601String(),
    };

    test('fromJson creates a valid instance', () {
      final notification = NotificationModel.fromJson(testJson);

      expect(notification.id, 1);
      expect(notification.title, 'Test Notification');
      expect(notification.body, 'This is a test body');
      expect(notification.data, {'key': 'value'});
      expect(notification.isRead, false);
      expect(notification.createdAt, testDate);
    });

    test('fromJson handles boolean is_read correctly', () {
      final jsonWithBool = Map<String, dynamic>.from(testJson);
      jsonWithBool['is_read'] = true;

      final notification = NotificationModel.fromJson(jsonWithBool);
      expect(notification.isRead, true);
    });

    test('fromJson handles integer is_read correctly', () {
      final jsonWithInt = Map<String, dynamic>.from(testJson);
      jsonWithInt['is_read'] = 1;

      final notification = NotificationModel.fromJson(jsonWithInt);
      expect(notification.isRead, true);
    });

    test('fromJson handles null data', () {
      final jsonWithNullData = Map<String, dynamic>.from(testJson);
      jsonWithNullData['data'] = null;

      final notification = NotificationModel.fromJson(jsonWithNullData);
      expect(notification.data, null);
    });
  });
}
