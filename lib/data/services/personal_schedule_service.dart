import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../models/personal_schedule_model.dart';
import 'auth_service.dart';

class PersonalScheduleService {
  final AuthService _authService = AuthService();

  // Get all personal schedules for current user
  Future<List<PersonalSchedule>> getPersonalSchedules() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Get personal schedules request');
      
      final response = await http.get(
        Uri.parse(ApiConstants.personalSchedules),
        headers: ApiConstants.headers(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> schedulesJson = data['data'];
        return schedulesJson
            .map((json) => PersonalSchedule.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to get personal schedules',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Get personal schedule request: $scheduleId');
      
      final response = await http.get(
        Uri.parse(ApiConstants.personalScheduleDetail(scheduleId)),
        headers: ApiConstants.headers(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PersonalSchedule.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Personal schedule not found');
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to get personal schedule',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Create personal schedule request');
      print('📝 Data: title=$title');
      
      final response = await http.post(
        Uri.parse(ApiConstants.personalSchedules),
        headers: ApiConstants.headers(token: token),
        body: json.encode({
          'title': title,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          if (location != null) 'location': location,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return PersonalSchedule.fromJson(data['data']);
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
          message: error['message'] ?? 'Failed to create personal schedule',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Update personal schedule request: $scheduleId');
      
      final requestBody = <String, dynamic>{};
      if (title != null) requestBody['title'] = title;
      if (startTime != null) requestBody['start_time'] = startTime.toIso8601String();
      if (endTime != null) requestBody['end_time'] = endTime.toIso8601String();
      if (location != null) requestBody['location'] = location;
      if (description != null) requestBody['description'] = description;
      if (color != null) requestBody['color'] = color;

      final response = await http.put(
        Uri.parse(ApiConstants.personalScheduleDetail(scheduleId)),
        headers: ApiConstants.headers(token: token),
        body: json.encode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PersonalSchedule.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Personal schedule not found');
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw ValidationException(
          message: error['message'] ?? 'Validation failed',
          errors: error['errors'],
        );
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to update personal schedule',
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
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No token found');
      }

      print('🔵 Delete personal schedule request: $scheduleId');
      
      final response = await http.delete(
        Uri.parse(ApiConstants.personalScheduleDetail(scheduleId)),
        headers: ApiConstants.headers(token: token),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Personal schedule not found');
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Failed to delete personal schedule',
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

