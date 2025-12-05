import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      debugPrint('🔵 Checking session via AuthProvider...');
      await authProvider.checkAuthStatus();

      if (authProvider.isAuthenticated) {
        debugPrint('✅ Session valid, redirecting to home');
        _goToHome();
      } else {
        debugPrint('🔴 Session invalid, redirecting to login');
        _goToLogin();
      }
    } catch (e) {
      debugPrint('❌ Error checking session: $e');
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
