import '../../core/errors/api_exception.dart';
import '../../core/http/dio_client.dart';
import '../models/classroom_model.dart';
import '../models/class_schedule_model.dart';

class ClassroomService {
  final DioClient _dioClient = DioClient();

  // Get all classrooms for current user
  Future<List<Classroom>> getClassrooms() async {
    try {
      print('🔵 Get classrooms request');

      final response = await _dioClient.get('/api/classrooms');

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> classroomsJson = response.data['data'];
        return classroomsJson.map((json) => Classroom.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Failed to get classrooms',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Get classrooms error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Get classroom by ID
  Future<Classroom> getClassroom(int classroomId) async {
    try {
      print('🔵 Get classroom request: $classroomId');

      final response = await _dioClient.get('/api/classrooms/$classroomId');

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return Classroom.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to get classroom',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Get classroom error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Create classroom
  Future<Classroom> createClassroom({
    required String name,
    String? description,
  }) async {
    try {
      print('🔵 Create classroom request');
      print('📝 Data: name=$name');

      final response = await _dioClient.post(
        '/api/classrooms',
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 201) {
        return Classroom.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to create classroom',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Create classroom error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Join classroom by code
  Future<Classroom> joinClassroom(String uniqueCode) async {
    try {
      print('🔵 Join classroom request: $uniqueCode');

      final response = await _dioClient.post(
        '/api/classrooms/join',
        data: {'unique_code': uniqueCode},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return Classroom.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to join classroom',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Join classroom error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Get class schedules for a classroom
  Future<List<ClassSchedule>> getClassSchedules(
    int classroomId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🔵 Get schedules request for classroom: $classroomId');

      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dioClient.get(
        '/api/classrooms/$classroomId/schedules',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> schedulesJson = response.data['data'];
        return schedulesJson
            .map((json) => ClassSchedule.fromJson(json))
            .toList();
      } else {
        throw ApiException(
          message: 'Failed to get schedules',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Get schedules error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Create class schedule
  Future<ClassSchedule> createClassSchedule({
    required int classroomId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? lecturer,
    String? description,
    String? color,
    int? coordinator1,
    int? coordinator2,
    List<int>? repeatDays,
    int? repeatCount,
    List<int>? reminders,
  }) async {
    try {
      print('🔵 Create schedule request for classroom: $classroomId');
      print('📝 Data: title=$title');

      final response = await _dioClient.post(
        '/api/classrooms/$classroomId/schedules',
        data: {
          'title': title,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          if (location != null) 'location': location,
          if (lecturer != null) 'lecturer': lecturer,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
          if (coordinator1 != null) 'coordinator_1': coordinator1,
          if (coordinator2 != null) 'coordinator_2': coordinator2,
          if (repeatDays != null && repeatDays.isNotEmpty)
            'repeat_days': repeatDays,
          if (repeatCount != null) 'repeat_count': repeatCount,
          if (reminders != null && reminders.isNotEmpty) 'reminders': reminders,
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data['data'];

        // Debug types
        if (data is Map) {
          print('🔍 Debugging types for ClassSchedule:');
          data.forEach((key, value) {
            print('Field: $key, Value: $value, Type: ${value.runtimeType}');
            if (value is List) {
              print('  List $key items:');
              for (var item in value) {
                print('    Item: $item, Type: ${item.runtimeType}');
                if (item is Map) {
                  item.forEach((k, v) {
                    print(
                      '      SubField: $k, Value: $v, Type: ${v.runtimeType}',
                    );
                  });
                }
              }
            }
          });
        }

        if (data is List) {
          // If it's a list (repeating schedule), return the first one
          // The provider will refresh the list anyway
          return ClassSchedule.fromJson(data.first);
        }
        return ClassSchedule.fromJson(data);
      } else {
        throw ApiException(
          message: 'Failed to create schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Create schedule error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Update class schedule
  Future<ClassSchedule> updateClassSchedule({
    required int classroomId,
    required int scheduleId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? lecturer,
    String? description,
    String? color,
    int? coordinator1,
    int? coordinator2,
    List<int>? reminders,
  }) async {
    try {
      print('🔵 Update schedule request: $scheduleId');

      // Build request body
      // Note: coordinator1 and coordinator2 are always included (even if null)
      // to allow clearing coordinators when editing
      final requestBody = <String, dynamic>{};
      if (title != null) requestBody['title'] = title;
      if (startTime != null)
        requestBody['start_time'] = startTime.toIso8601String();
      if (endTime != null) requestBody['end_time'] = endTime.toIso8601String();
      if (location != null) requestBody['location'] = location;
      if (lecturer != null) requestBody['lecturer'] = lecturer;
      if (description != null) requestBody['description'] = description;
      if (color != null) requestBody['color'] = color;
      if (reminders != null) requestBody['reminders'] = reminders;

      // Always include coordinator fields to allow setting them to null
      // This is needed for edit functionality where user can clear coordinators
      requestBody['coordinator_1'] = coordinator1;
      requestBody['coordinator_2'] = coordinator2;

      final response = await _dioClient.put(
        '/api/classrooms/$classroomId/schedules/$scheduleId',
        data: requestBody,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return ClassSchedule.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to update schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Update schedule error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Delete class schedule
  Future<void> deleteClassSchedule({
    required int classroomId,
    required int scheduleId,
  }) async {
    try {
      print('🔵 Delete schedule request: $scheduleId');

      final response = await _dioClient.delete(
        '/api/classrooms/$classroomId/schedules/$scheduleId',
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw ApiException(
          message: 'Failed to delete schedule',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Delete schedule error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Leave classroom
  Future<void> leaveClassroom(int classroomId) async {
    try {
      print('🔵 Leave classroom request: $classroomId');

      final response = await _dioClient.post(
        '/api/classrooms/$classroomId/leave',
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw ApiException(
          message: 'Failed to leave classroom',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Leave classroom error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Remove member
  Future<void> removeMember({
    required int classroomId,
    required int userId,
  }) async {
    try {
      print('🔵 Remove member request: classroom=$classroomId, user=$userId');

      final response = await _dioClient.post(
        '/api/classrooms/$classroomId/remove-member',
        data: {'user_id': userId},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw ApiException(
          message: 'Failed to remove member',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Remove member error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Transfer ownership
  Future<void> transferOwnership({
    required int classroomId,
    required int newOwnerId,
  }) async {
    try {
      print(
        '🔵 Transfer ownership request: classroom=$classroomId, newOwner=$newOwnerId',
      );

      final response = await _dioClient.post(
        '/api/classrooms/$classroomId/transfer-ownership',
        data: {'new_owner_id': newOwnerId},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw ApiException(
          message: 'Failed to transfer ownership',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Transfer ownership error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Update classroom description
  Future<Classroom> updateClassroomDescription({
    required int classroomId,
    String? description,
  }) async {
    try {
      print('🔵 Update classroom description request: $classroomId');

      final response = await _dioClient.put(
        '/api/classrooms/$classroomId',
        data: {'description': description},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return Classroom.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to update classroom',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Update classroom error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Delete classroom
  Future<void> deleteClassroom(int classroomId) async {
    try {
      print('🔵 Delete classroom request: $classroomId');

      final response = await _dioClient.delete('/api/classrooms/$classroomId');

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw ApiException(
          message: 'Failed to delete classroom',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Delete classroom error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
