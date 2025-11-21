class ApiConstants {
  // DEVELOPMENT vs PRODUCTION
  // Uncomment salah satu baseUrl sesuai kebutuhan:
  
  // VERCEL PREVIEW (Latest deployment):
  static const String baseUrl = 'https://studify-backend-api-dev.onrender.com';
  
  // VERCEL DEV BRANCH:
  // static const String baseUrl = 'https://studify-git-dev-zidnafazs-projects.vercel.app';
  
  // LOCAL DEVELOPMENT (Laravel artisan serve):
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:8000'; // iOS/Web
  
  // PRODUCTION (Vercel):
  // static const String baseUrl = 'https://studify-ten.vercel.app';
  
  // Auth Endpoints
  static const String register = '$baseUrl/api/users';
  static const String login = '$baseUrl/api/auth/login';
  static const String logout = '$baseUrl/api/auth/login';
  static const String refresh = '$baseUrl/api/auth/refresh';
  static const String me = '$baseUrl/api/auth/user';
  
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
