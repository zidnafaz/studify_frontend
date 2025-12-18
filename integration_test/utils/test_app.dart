import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:studify/l10n/generated/app_localizations.dart';
import 'package:studify/core/constants/app_theme.dart';
import 'package:studify/providers/auth_provider.dart';
import 'package:studify/providers/classroom_provider.dart';
import 'package:studify/providers/theme_provider.dart';
import 'package:studify/providers/locale_provider.dart';
import 'package:studify/providers/personal_schedule_provider.dart';
import 'package:studify/providers/combined_schedule_provider.dart';

import 'package:studify/data/services/notification_service.dart';
import 'package:studify/data/services/combined_schedule_service.dart';
import 'package:studify/data/services/device_token_service.dart';
import 'package:studify/providers/notification_provider.dart';
import 'package:studify/data/services/auth_service.dart';
import 'package:studify/data/services/classroom_service.dart';
import 'package:studify/data/services/personal_schedule_service.dart';
import 'package:studify/data/services/class_schedule_service.dart';
import 'package:studify/presentation/screens/auth/welcome_screen.dart';
import 'package:studify/presentation/screens/auth/login_screen.dart';
import 'package:studify/presentation/screens/auth/register_screen.dart';
import 'package:studify/presentation/screens/home/home_screen.dart';
import 'package:studify/presentation/screens/classroom/classroom_list_screen.dart';
import 'package:studify/presentation/screens/classroom/classroom_detail_screen.dart';
import 'package:studify/data/models/classroom_model.dart';

class TestApp extends StatelessWidget {
  final AuthService authService;
  final ClassroomService classroomService;
  final PersonalScheduleService personalScheduleService;
  final ClassScheduleService classScheduleService;
  final NotificationService? notificationService;
  final CombinedScheduleService? combinedScheduleService;
  final DeviceTokenService? deviceTokenService;

  final String? initialRoute;

  const TestApp({
    super.key,
    required this.authService,
    required this.classroomService,
    required this.personalScheduleService,
    required this.classScheduleService,
    this.notificationService,
    this.combinedScheduleService,
    this.deviceTokenService,
    this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ClassroomProvider(service: classroomService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              PersonalScheduleProvider(service: personalScheduleService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CombinedScheduleProvider(service: combinedScheduleService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(service: notificationService),
        ),
        Provider(create: (_) => deviceTokenService ?? DeviceTokenService()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            title: 'Studify Test',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: AppTheme.lightTheme,
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('id')],
            initialRoute: initialRoute ?? '/',
            // home: const WelcomeScreen(), // Use initialRoute instead of home for better control
            routes: {
              '/': (context) => const WelcomeScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/classroomList': (context) => const ClassroomScreen(),
              '/classroomDetail': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments as Classroom;
                return ClassroomDetailScreen(classroom: args);
              },
            },
          );
        },
      ),
    );
  }
}
