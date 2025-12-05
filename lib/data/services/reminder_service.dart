import 'package:dio/dio.dart';
import '../../core/http/dio_client.dart';
import '../../core/errors/api_exception.dart';

class ReminderService {
  final DioClient _dioClient = DioClient();

  // Create Reminder
  Future<void> createReminder({
    required int remindableId,
    required String remindableType, // 'class_schedule' or 'personal_schedule'
    required int minutesBeforeStart,
  }) async {
    try {
      await _dioClient.post(
        '/api/reminders',
        data: {
          'remindable_id': remindableId,
          'remindable_type': remindableType,
          'minutes_before_start': minutesBeforeStart,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Update Reminder
  Future<void> updateReminder({
    required int reminderId,
    required int minutesBeforeStart,
  }) async {
    try {
      await _dioClient.put(
        '/api/reminders/$reminderId',
        data: {'minutes_before_start': minutesBeforeStart},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Delete Reminder
  Future<void> deleteReminder(int reminderId) async {
    try {
      await _dioClient.delete('/api/reminders/$reminderId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      return ApiException(
        message: data is Map && data['message'] != null
            ? data['message']
            : 'An error occurred',
        statusCode: error.response!.statusCode,
      );
    }
    return ApiException(message: error.message ?? 'Unknown error');
  }
}
