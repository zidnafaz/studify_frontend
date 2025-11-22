import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studify/core/http/dio_client.dart';
import 'package:studify/data/services/auth_service.dart';
import 'package:studify/core/errors/api_exception.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final DioClient _dioClient = DioClient();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // 1. Ambil token dari storage
      String? token = await _authService.getToken();

      // 2. Kalau tidak ada token, langsung tendang ke Login
      if (token == null) {
        debugPrint('🔴 No token found, redirecting to login');
        _goToLogin();
        return;
      }

      // 3. Kalau ada token, cek apakah masih valid?
      // Kita coba panggil endpoint user profile /me
      debugPrint('🔵 Checking token validity...');
      try {
        // Gunakan DioClient yang sudah ada Interceptor-nya!
        final response = await _dioClient.get('/api/auth/user');

        if (response.statusCode == 200) {
          // Token Valid & Masih Hidup -> Masuk Home
          debugPrint('✅ Token valid, redirecting to home');
          _goToHome();
        } else {
          // Harusnya kena interceptor, tapi kalau lolos kesini berarti gagal total
          debugPrint('❌ Invalid response status: ${response.statusCode}');
          _goToLogin();
        }
      } catch (e) {
        // 4. Disini kuncinya!
        // Jika errornya 401, Interceptor Anda (jika benar) harusnya sudah mencoba refresh.
        // Jika Interceptor berhasil refresh, dia akan mengulang request '/api/auth/user' dan masuk ke 'try' lagi (sukses).
        // TAPI, jika Interceptor GAGAL refresh (karena refresh token juga expired), dia akan melempar error kesini.

        debugPrint('❌ Error checking token: $e');

        if (e is UnauthorizedException) {
          // Token invalid atau refresh gagal
          debugPrint('🔴 Unauthorized, redirecting to login');
          await _authService.clearAuthData();
          _goToLogin();
        } else if (e is ApiException) {
          // Error lainnya
          debugPrint('🔴 API Error: ${e.message}');
          _goToLogin();
        } else {
          // Network error atau error lainnya
          debugPrint('🔴 Unknown error: $e');
          // Untuk network error, mungkin user masih bisa masuk dengan token yang ada
          // Tapi lebih aman redirect ke login
          _goToLogin();
        }
      }
    } catch (e) {
      debugPrint('❌ Fatal error in _checkSession: $e');
      _goToLogin();
    }
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo dari assets dengan shadow seperti di login_screen
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(4, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/logo/logo_app.svg',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
