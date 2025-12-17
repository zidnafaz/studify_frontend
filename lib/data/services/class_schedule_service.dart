import '../../core/errors/api_exception.dart';
import '../../core/http/dio_client.dart';
import '../models/class_schedule_model.dart';

class ClassScheduleService {
  final DioClient _dioClient;

  ClassScheduleService({DioClient? client}) : _dioClient = client ?? DioClient();

  // Get all schedules for a classroom
  Future<List<ClassSchedule>> getClassSchedules(int classroomId) async {
    try {
      final response = await _dioClient.get(
        '/api/classrooms/$classroomId/schedules',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ClassSchedule.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Failed to get class schedules',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Create a new class schedule
  Future<ClassSchedule> createClassSchedule(
    int classroomId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dioClient.post(
        '/api/classrooms/$classroomId/schedules',
        data: data,
      );

      if (response.statusCode == 201) {
        return ClassSchedule.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to create class schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Update a class schedule
  Future<ClassSchedule> updateClassSchedule(
    int classroomId,
    int scheduleId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dioClient.put(
        '/api/classrooms/$classroomId/schedules/$scheduleId',
        data: data,
      );

      if (response.statusCode == 200) {
        return ClassSchedule.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to update class schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Delete a class schedule
  Future<void> deleteClassSchedule(int classroomId, int scheduleId) async {
    try {
      final response = await _dioClient.delete(
        '/api/classrooms/$classroomId/schedules/$scheduleId',
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Failed to delete class schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
