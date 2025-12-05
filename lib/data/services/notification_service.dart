import '../models/notification_model.dart';
import '../../core/http/dio_client.dart';

class NotificationService {
  final DioClient _dioClient = DioClient();

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _dioClient.get('/api/notifications');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dioClient.patch('/api/notifications/$id/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dioClient.patch('/api/notifications/read-all');
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }
}
