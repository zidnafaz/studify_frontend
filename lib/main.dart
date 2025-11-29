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
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'core/constants/app_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClassroomProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => PersonalScheduleProvider()),
        ChangeNotifierProvider(create: (_) => CombinedScheduleProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Studify',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColor.primary,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColor.primary,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true),
            ),
            home: const AuthWrapper(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),

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
