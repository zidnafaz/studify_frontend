class ApiConstants {
  // DEVELOPMENT vs PRODUCTION
  // Uncomment salah satu baseUrl sesuai kebutuhan:
  
  // LOCAL DEVELOPMENT (Laravel artisan serve):
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:8000'; // iOS/Web
  
  // RENDER (Latest deployment) - dev branch:
  static const String baseUrl = 'https://studify-backend-api-dev.onrender.com';
  
  // Auth Endpoints
  static const String register = '$baseUrl/api/users';
  static const String login = '$baseUrl/api/auth/login';
  static const String logout = '$baseUrl/api/auth/login';
  static const String refresh = '$baseUrl/api/auth/refresh';
  static const String me = '$baseUrl/api/auth/user';
  
  // Classroom Endpoints
  static const String classrooms = '$baseUrl/api/classrooms';
  static String classroomDetail(int id) => '$baseUrl/api/classrooms/$id';
  static const String classroomJoin = '$baseUrl/api/classrooms/join';
  static String classroomLeave(int id) => '$baseUrl/api/classrooms/$id/leave';
  static String classroomRemoveMember(int id) => '$baseUrl/api/classrooms/$id/remove-member';
  static String classroomTransferOwnership(int id) => '$baseUrl/api/classrooms/$id/transfer-ownership';
  
  // Class Schedule Endpoints
  static String classSchedules(int classroomId) => '$baseUrl/api/classrooms/$classroomId/schedules';
  static String classScheduleDetail(int classroomId, int scheduleId) => '$baseUrl/api/classrooms/$classroomId/schedules/$scheduleId';
  
  // Personal Schedule Endpoints
  static const String personalSchedules = '$baseUrl/api/personal-schedules';
  static String personalScheduleDetail(int scheduleId) => '$baseUrl/api/personal-schedules/$scheduleId';
  
  // Headers
  static Map<String, String> headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}