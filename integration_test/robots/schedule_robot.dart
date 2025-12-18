import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ScheduleRobot {
  final WidgetTester tester;

  ScheduleRobot(this.tester);

  // Finders
  Finder get addScheduleFab => find.byKey(const Key('home_add_schedule_fab'));
  Finder get titleField => find.byKey(const Key('schedule_title_field'));
  Finder get saveButton => find.text('Save'); // Localized 'Simpan' or 'Save'

  // Actions
  Future<void> openAddScheduleSheet() async {
    await tester.tap(addScheduleFab);
    await tester.pumpAndSettle();
  }

  Future<void> addPersonalSchedule({required String title}) async {
    await tester.enterText(titleField, title);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  Future<void> enterTitle(String title) async {
    await tester.enterText(titleField, title);
    await tester.pump();
  }

  Future<void> saveSchedule() async {
    // Find Save button (text or icon)
    // Assuming it's a text button 'Save' or checkmark icon
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  Future<void> verifySchedulePresent(String title) async {
    expect(find.text(title), findsOneWidget);
  }
}
