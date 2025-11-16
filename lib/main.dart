import 'package:flutter/material.dart';
import 'features/classroom/classroom_list_screen.dart';
import 'core/constants/app_color.dart';

void main() {
  runApp(const StudifyApp());
}

class StudifyApp extends StatelessWidget {
  const StudifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Studify',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColor.primary,
        ),
      ),
      home: const ClassroomListScreen(),
    );
  }
}
