import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../models/classroom_model.dart';
import '../models/class_schedule_model.dart';
import 'auth_service.dart';

class ClassroomService {
  final AuthService _authService = AuthService();

  // Get all classrooms for current user
  Future<List<Classroom>> getClassrooms() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Get classrooms request');
      
      final response = await http.get(
        Uri.parse(ApiConstants.classrooms),
        headers: ApiConstants.headers(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> classroomsJson = data['data'];
        return classroomsJson
            .map((json) => Classroom.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Unauthorized',
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to get classrooms',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Get classroom request: $classroomId');
      
      final response = await http.get(
        Uri.parse(ApiConstants.classroomDetail(classroomId)),
        headers: ApiConstants.headers(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Classroom.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Classroom not found');
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to get classroom',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Create classroom request');
      print('📝 Data: name=$name');
      
      final response = await http.post(
        Uri.parse(ApiConstants.classrooms),
        headers: ApiConstants.headers(token: token),
        body: json.encode({
          'name': name,
          if (description != null) 'description': description,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Classroom.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw ValidationException(
          message: error['message'] ?? 'Validation failed',
          errors: error['errors'],
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to create classroom',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Join classroom request: $uniqueCode');
      
      final response = await http.post(
        Uri.parse(ApiConstants.classroomJoin),
        headers: ApiConstants.headers(token: token),
        body: json.encode({
          'unique_code': uniqueCode,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Classroom.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Classroom not found');
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw ValidationException(
          message: error['message'] ?? 'Validation failed',
          errors: error['errors'],
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to join classroom',
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
  Future<List<ClassSchedule>> getClassSchedules(int classroomId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Get schedules request for classroom: $classroomId');
      
      final response = await http.get(
        Uri.parse(ApiConstants.classSchedules(classroomId)),
        headers: ApiConstants.headers(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> schedulesJson = data['data'];
        return schedulesJson
            .map((json) => ClassSchedule.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Classroom not found');
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to get schedules',
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
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Create schedule request for classroom: $classroomId');
      print('📝 Data: title=$title');
      
      final response = await http.post(
        Uri.parse(ApiConstants.classSchedules(classroomId)),
        headers: ApiConstants.headers(token: token),
        body: json.encode({
          'title': title,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          if (location != null) 'location': location,
          if (lecturer != null) 'lecturer': lecturer,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
          if (coordinator1 != null) 'coordinator_1': coordinator1,
          if (coordinator2 != null) 'coordinator_2': coordinator2,
          if (repeatDays != null && repeatDays.isNotEmpty) 'repeat_days': repeatDays,
          if (repeatCount != null) 'repeat_count': repeatCount,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ClassSchedule.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 403) {
        throw ForbiddenException(
          message: 'You are not authorized to create schedules',
        );
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw ValidationException(
          message: error['message'] ?? 'Validation failed',
          errors: error['errors'],
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to create schedule',
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
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Update schedule request: $scheduleId');
      
      // Build request body
      // Note: coordinator1 and coordinator2 are always included (even if null)
      // to allow clearing coordinators when editing
      final requestBody = <String, dynamic>{};
      if (title != null) requestBody['title'] = title;
      if (startTime != null) requestBody['start_time'] = startTime.toIso8601String();
      if (endTime != null) requestBody['end_time'] = endTime.toIso8601String();
      if (location != null) requestBody['location'] = location;
      if (lecturer != null) requestBody['lecturer'] = lecturer;
      if (description != null) requestBody['description'] = description;
      if (color != null) requestBody['color'] = color;
      
      // Always include coordinator fields to allow setting them to null
      // This is needed for edit functionality where user can clear coordinators
      requestBody['coordinator_1'] = coordinator1;
      requestBody['coordinator_2'] = coordinator2;

      final response = await http.put(
        Uri.parse(ApiConstants.classScheduleDetail(classroomId, scheduleId)),
        headers: ApiConstants.headers(token: token),
        body: json.encode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ClassSchedule.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 403) {
        throw ForbiddenException(
          message: 'You are not authorized to update this schedule',
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Schedule not found');
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw ValidationException(
          message: error['message'] ?? 'Validation failed',
          errors: error['errors'],
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to update schedule',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Delete schedule request: $scheduleId');
      
      final response = await http.delete(
        Uri.parse(ApiConstants.classScheduleDetail(classroomId, scheduleId)),
        headers: ApiConstants.headers(token: token),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 403) {
        throw ForbiddenException(
          message: 'You are not authorized to delete this schedule',
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Schedule not found');
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to delete schedule',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Leave classroom request: $classroomId');
      
      final response = await http.post(
        Uri.parse(ApiConstants.classroomLeave(classroomId)),
        headers: ApiConstants.headers(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 403) {
        final error = json.decode(response.body);
        throw ForbiddenException(
          message: error['message'] ?? 'You cannot leave this classroom',
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Classroom not found');
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to leave classroom',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Remove member request: classroom=$classroomId, user=$userId');
      
      final response = await http.post(
        Uri.parse(ApiConstants.classroomRemoveMember(classroomId)),
        headers: ApiConstants.headers(token: token),
        body: json.encode({
          'user_id': userId,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 403) {
        throw ForbiddenException(
          message: 'Only the owner can remove members',
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Classroom or user not found');
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw ValidationException(
          message: error['message'] ?? 'Validation failed',
          errors: error['errors'],
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to remove member',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Transfer ownership request: classroom=$classroomId, newOwner=$newOwnerId');
      
      final response = await http.post(
        Uri.parse(ApiConstants.classroomTransferOwnership(classroomId)),
        headers: ApiConstants.headers(token: token),
        body: json.encode({
          'new_owner_id': newOwnerId,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 403) {
        throw ForbiddenException(
          message: 'Only the owner can transfer ownership',
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Classroom or user not found');
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw ValidationException(
          message: error['message'] ?? 'Validation failed',
          errors: error['errors'],
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to transfer ownership',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Update classroom description request: $classroomId');
      
      final response = await http.put(
        Uri.parse(ApiConstants.classroomDetail(classroomId)),
        headers: ApiConstants.headers(token: token),
        body: json.encode({
          'description': description,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Classroom.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 403) {
        throw ForbiddenException(
          message: 'Only the owner can update the classroom',
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Classroom not found');
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw ValidationException(
          message: error['message'] ?? 'Validation failed',
          errors: error['errors'],
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to update classroom',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Update classroom error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
