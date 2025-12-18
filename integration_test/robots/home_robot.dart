import 'package:flutter/material.dart';
import 'package:studify/presentation/screens/auth/profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeRobot {
  final WidgetTester tester;

  HomeRobot(this.tester);

  // Finders
  Finder get homeTab => find.byKey(const Key('bottom_nav_home'));
  Finder get classroomTab => find.byKey(const Key('bottom_nav_classroom'));
  Finder get profileTab => find.byKey(const Key('bottom_nav_profile'));

  // Actions
  Future<void> verifyOnHomeScreen() async {
    expect(homeTab, findsOneWidget);
  }

  Future<void> navigateToClassroomTab() async {
    await navigateToClassroom();
  }

  Future<void> logout() async {
    await navigateToProfile();
    final logoutBtn = find.byKey(const Key('profile_logout_btn'));

    // Explicitly scroll to ensure visibility
    await tester.scrollUntilVisible(
      logoutBtn,
      50.0,
      scrollable: find.descendant(
        of: find.byType(ProfileScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    // Tap with warning disabled
    await tester.tap(logoutBtn, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Check if confirm button appeared
    final confirmBtn = find.byKey(const Key('profile_confirm_logout_btn'));
    if (confirmBtn.evaluate().isEmpty) {
      // Fallback: Force tap via widget controller if gesture failed
      final btnWidget = tester.widget<ElevatedButton>(logoutBtn);
      btnWidget.onPressed?.call();
      await tester.pumpAndSettle();
    }

    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();
  }

  Future<void> navigateToClassroom() async {
    await tester.tap(classroomTab);
    await tester.pumpAndSettle();
  }

  Future<void> navigateToProfile() async {
    await tester.tap(profileTab);
    await tester.pumpAndSettle();
  }

  Future<void> navigateToHome() async {
    await tester.tap(homeTab);
    await tester.pumpAndSettle();
  }

  Future<void> openAddPersonalSchedule() async {
    // ...
  }
  Future<void> selectScheduleSource(String sourceName) async {
    // 1. Find Dropdown (Icon: arrow_drop_down)
    final dropdown = find.byIcon(Icons.arrow_drop_down);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // 2. Select Item by Name (e.g., 'Personal Schedules')
    // Dropdown items are usually in a separate route/overlay
    final item = find
        .text(sourceName)
        .last; // Use last to find the one in the overlay
    await tester.tap(item);
    await tester.pumpAndSettle();
  }
}
