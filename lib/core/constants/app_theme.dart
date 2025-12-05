import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  // ================= LIGHT THEME =================
  static ColorScheme get lightColorScheme {
    return const ColorScheme(
      brightness: Brightness.light,

      // Primary (Navy)
      primary: AppColor.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(
        0xFFE0E0FF,
      ), // Versi pudar dari navy untuk container
      onPrimaryContainer: AppColor.primary,

      // Secondary (Teal)
      secondary: AppColor.secondary,
      onSecondary: Color(0xFF00382E), // Text gelap di atas teal agar terbaca
      secondaryContainer: Color(0xFFD0F8F1),
      onSecondaryContainer: Color(0xFF004F42),

      // Accent / Tertiary
      tertiary: AppColor.accent,
      onTertiary: Colors.white,

      // Error
      error: AppColor.scheduleRed,
      onError: Colors.white,

      // Background & Surface
      surface: AppColor.backgroundSecondary, // Card color
      onSurface: AppColor.textPrimary, // Text color on card
      background: AppColor.backgroundPrimary, // Scaffold color
      onBackground: AppColor.textPrimary,

      // Outline/Border
      outline: Color(0xFFE0E0E0),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: AppColor.backgroundPrimary,

      // Font Style (Optional: Ganti dengan GoogleFonts.poppinsTextTheme() jika mau)
      fontFamily: 'Poppins', // Pastikan font sudah didaftarkan di pubspec.yaml
      // AppBar Cantik
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.backgroundPrimary,
        surfaceTintColor:
            Colors.transparent, // Biar tidak berubah warna saat scroll
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColor.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Input Field
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.primary, width: 2),
        ),
      ),

      // Tombol Utama
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }

  // ================= DARK THEME =================
  static ColorScheme get darkColorScheme {
    return const ColorScheme(
      brightness: Brightness.dark,

      // Primary: Harus lebih terang di dark mode (Light Indigo)
      primary: Color(0xFF8EA3FF),
      onPrimary: Color(0xFF00154D), // Text gelap di atas primary terang
      primaryContainer: Color(0xFF263366),
      onPrimaryContainer: Color(0xFFDEE0FF),

      // Secondary: Teal tetap bagus, tapi sesuaikan containernya
      secondary: AppColor.secondary,
      onSecondary: Color(0xFF00382E),
      secondaryContainer: Color(0xFF004F42),
      onSecondaryContainer: Color(0xFF98F3E2),

      // Backgrounds (Dark Navy Grey - Lebih elegan dari Hitam total)
      surface: Color(0xFF1C1D29),
      onSurface: Color(0xFFE6E6E6),
      background: Color(0xFF0F1016), // Background scaffold
      onBackground: Color(0xFFE6E6E6),

      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),

      outline: Color(0xFF444444),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F1016), // Very dark navy

      fontFamily: 'Poppins',

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F1016),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1C1D29), // Surface color
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF333333),
          ), // Border halus di dark mode
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1D29),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColor.secondary,
            width: 2,
          ), // Fokus pakai warna Teal
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8EA3FF), // Light Indigo
          foregroundColor: const Color(0xFF00154D), // Dark text
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
