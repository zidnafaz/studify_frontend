import '../../core/errors/api_exception.dart';
import '../../core/http/dio_client.dart';
import '../models/personal_schedule_model.dart';

class PersonalScheduleService {
  final DioClient _dioClient = DioClient();

  // Get all personal schedules for current user
  Future<List<PersonalSchedule>> getPersonalSchedules() async {
    try {
      print('🔵 Get personal schedules request');
      
      final response = await _dioClient.get('/api/personal-schedules');

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> schedulesJson = response.data['data'];
        return schedulesJson
            .map((json) => PersonalSchedule.fromJson(json))
            .toList();
      } else {
        throw ApiException(
          message: 'Failed to get personal schedules',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Get personal schedules error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Get personal schedule by ID
  Future<PersonalSchedule> getPersonalSchedule(int scheduleId) async {
    try {
      print('🔵 Get personal schedule request: $scheduleId');
      
      final response = await _dioClient.get('/api/personal-schedules/$scheduleId');

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return PersonalSchedule.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to get personal schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Get personal schedule error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Create personal schedule
  Future<PersonalSchedule> createPersonalSchedule({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? description,
    String? color,
  }) async {
    try {
      print('🔵 Create personal schedule request');
      print('📝 Data: title=$title');
      
      final response = await _dioClient.post(
        '/api/personal-schedules',
        data: {
          'title': title,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          if (location != null) 'location': location,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 201) {
        return PersonalSchedule.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to create personal schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Create personal schedule error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Update personal schedule
  Future<PersonalSchedule> updatePersonalSchedule({
    required int scheduleId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    String? color,
  }) async {
    try {
      print('🔵 Update personal schedule request: $scheduleId');
      
      final requestBody = <String, dynamic>{};
      if (title != null) requestBody['title'] = title;
      if (startTime != null) requestBody['start_time'] = startTime.toIso8601String();
      if (endTime != null) requestBody['end_time'] = endTime.toIso8601String();
      if (location != null) requestBody['location'] = location;
      if (description != null) requestBody['description'] = description;
      if (color != null) requestBody['color'] = color;

      final response = await _dioClient.put(
        '/api/personal-schedules/$scheduleId',
        data: requestBody,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return PersonalSchedule.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to update personal schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Update personal schedule error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Delete personal schedule
  Future<void> deletePersonalSchedule(int scheduleId) async {
    try {
      print('🔵 Delete personal schedule request: $scheduleId');
      
      final response = await _dioClient.delete('/api/personal-schedules/$scheduleId');

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw ApiException(
          message: 'Failed to delete personal schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Delete personal schedule error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}

