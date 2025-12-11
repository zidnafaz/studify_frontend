import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/services/device_token_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _checkSession();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
  }

  Future<void> _checkSession() async {
    // Request notification permission immediately on app start
    try {
      await context.read<DeviceTokenService>().requestPermission();
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }

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
            if (_version.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Version $_version',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
