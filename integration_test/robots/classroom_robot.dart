import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

class ClassroomRobot {
  final WidgetTester tester;

  ClassroomRobot(this.tester);

  // List Screen Finders
  Finder get fab => find.byType(FloatingActionButton);
  Finder get createClassOption =>
      find.text('Create Class'); // Locale might differ
  Finder get joinClassOption => find.text('Join Class');

  // Create Screen Finders
  Finder get classNameField => find.byKey(const Key('create_class_name'));
  Finder get classDescField => find.byKey(const Key('create_class_desc'));
  Finder get createSubmitBtn => find.byKey(const Key('create_class_submit'));

  // Detail Screen Finders
  Finder getClassroomCard(String name) => find.text(name);

  // Actions
  Future<void> openCreateClassroom() async {
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Tap "Create Class" from sheet
    // Note: Localization dependent. Ideally use Keys in Sheet too.
    // For now, assuming English "Create Class" or adding Key to that ListTile.
    await tester.tap(find.byKey(const Key('sheet_create_class')));
    await tester.pumpAndSettle();
  }

  Future<void> createClassroom(String name, String desc) async {
    await tester.enterText(classNameField, name);
    await tester.enterText(classDescField, desc);
    await tester.tap(createSubmitBtn);
    await tester.pumpAndSettle();
  }

  Future<void> verifyOnClassroomListScreen() async {
    expect(fab, findsOneWidget);
  }

  Future<void> verifyOnClassroomDetailScreen() async {
    // Check for some element unique to detail, e.g. "Members" or class title in AppBar
    // Since title is dynamic, checking for tabs or "Stream" / "Members"
    // Assuming Detail has a TabBar with "Stream" (or similar)
    // Or just check that we are not on list.
    // Verify unique element on Detail Screen.
    // Since title is dynamic, we can check for the "Stream" or "Schedule" header or similar.
    // Checking code: _getScheduleHeaderText() returns localizable strings.
    // Or check for the Calendar widget type.
    // TableCalendar generic type mismatch might cause failures.
    // Using filter list icon as a unique identifier for detail screen.
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
  }

  Future<void> openClassroomDetail(String name) async {
    final card = getClassroomCard(name);
    await tester.scrollUntilVisible(card, 50.0);
    await tester.tap(card);
    await tester.pumpAndSettle();
  }

  // Class Schedule Actions
  Future<void> openAddClassSchedule() async {
    // Determine if we are on Detail screen
    // Tap FAB. Note: FAB is same type as on list screen.
    // Ensure we are on Detail checks?
    await tester.tap(fab);
    await tester.pumpAndSettle();
  }

  Future<void> addClassSchedule({
    required String title,
    String? lecturer,
    String? location,
  }) async {
    await tester.enterText(
      find.byKey(const Key('class_schedule_title')),
      title,
    );
    if (lecturer != null) {
      await tester.enterText(
        find.byKey(const Key('class_schedule_lecturer')),
        lecturer,
      );
    }
    if (location != null) {
      await tester.enterText(
        find.byKey(const Key('class_schedule_location')),
        location,
      );
    }

    // Tap Save
    await tester.tap(find.byKey(const Key('class_schedule_save_btn')));
    await tester.pumpAndSettle();
  }

  Future<void> verifyScheduleInList(String title) async {
    expect(find.text(title), findsOneWidget);
  }

  // Member Management Actions (F-03)
  Future<void> openJoinClassroom() async {
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sheet_join_class')));
    await tester.pumpAndSettle();
  }

  Future<void> joinClassroom(String code) async {
    await tester.enterText(
      find.byKey(const Key('join_class_code_field')),
      code,
    );
    await tester.tap(find.byKey(const Key('join_class_submit_btn')));
    await tester.pumpAndSettle();
  }

  Future<void> openClassroomInfo() async {
    // Tap More Vert -> View Detail
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Find "View Detail" text. Note: Localization dependent.
    // Assuming English "View Detail" or ideally add Key to PopupMenuItem.
    // Scanning file: value is 'detail'.
    // We can tap by text "View Detail".
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();
  }

  Future<String> getClassroomCode() async {
    final codeFinder = find.byKey(const Key('classroom_info_code'));
    expect(codeFinder, findsOneWidget);
    final textWidget = tester.widget<Text>(codeFinder);
    return textWidget.data!;
  }

  Future<void> verifyMemberInList(String name) async {
    final finder = find.text(name);
    // Explicitly target the first Scrollable (usually the main one)
    final primaryScrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      finder,
      50.0,
      scrollable: primaryScrollable,
    );
    await tester.pumpAndSettle();

    expect(finder, findsOneWidget);
  }
}
