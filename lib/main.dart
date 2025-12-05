import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studify/data/models/classroom_model.dart';
import 'package:studify/presentation/screens/classroom/classroom_detail_screen.dart';
import 'package:studify/presentation/screens/classroom/classroom_info_screen.dart';
import 'package:studify/presentation/screens/classroom/classroom_list_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/classroom_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/personal_schedule_provider.dart';
import 'providers/combined_schedule_provider.dart';
import 'providers/notification_provider.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/notification/notification_screen.dart';
import 'core/constants/app_theme.dart';
import 'data/services/device_token_service.dart';
import 'core/services/deep_link_service.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkService().init(MyApp.navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClassroomProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => PersonalScheduleProvider()),
        ChangeNotifierProvider(create: (_) => CombinedScheduleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        Provider(create: (_) => DeviceTokenService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: MyApp.navigatorKey,
            title: 'Studify',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/notifications': (context) => const NotificationScreen(),

              // Classroom
              '/classroomList': (context) => const ClassroomScreen(),
              '/classroomDetail': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments as Classroom;
                return ClassroomDetailScreen(classroom: args);
              },
              '/classroomInfo': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments as Classroom;
                return ClassroomInfoScreen(classroom: args);
              },
            },
          );
        },
      ),
    );
  }
}
