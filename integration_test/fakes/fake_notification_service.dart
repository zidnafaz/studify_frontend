import 'package:studify/data/models/notification_model.dart';
import 'package:studify/data/services/notification_service.dart';

class FakeNotificationService implements NotificationService {
  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    return [];
  }

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> markAsRead(int id) async {}
}
