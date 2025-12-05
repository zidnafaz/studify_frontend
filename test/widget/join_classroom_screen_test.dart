import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:studify/presentation/screens/classroom/join_classroom_screen.dart';
import 'package:studify/providers/classroom_provider.dart';
import 'package:studify/core/constants/app_theme.dart';
import 'package:studify/providers/theme_provider.dart';

// Create a MockClassroomProvider
class MockClassroomProvider extends Mock implements ClassroomProvider {}

void main() {
  testWidgets('JoinClassroomScreen populates text field with initialCode', (
    WidgetTester tester,
  ) async {
    // Arrange
    const initialCode = 'TESTCODE';

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ClassroomProvider>(
            create: (_) =>
                ClassroomProvider(), // Use real provider or mock if needed
          ),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const JoinClassroomScreen(initialCode: initialCode),
        ),
      ),
    );

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text(initialCode), findsOneWidget);
    expect(find.widgetWithText(TextFormField, initialCode), findsOneWidget);
  });

  testWidgets('JoinClassroomScreen shows validation error for empty code', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ClassroomProvider>(
            create: (_) => ClassroomProvider(),
          ),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const JoinClassroomScreen(),
        ),
      ),
    );

    // Act
    final joinButton = find.text('Join Class');
    await tester.tap(joinButton);
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Kode tidak boleh kosong'), findsOneWidget);
  });
}
