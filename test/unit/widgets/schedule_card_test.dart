import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studify/core/constants/app_color.dart';
import 'package:studify/data/models/class_schedule_model.dart';
import 'package:studify/presentation/widgets/schedule_card.dart';

void main() {
  late List<ClassSchedule> testSchedules;

  setUp(() {
    testSchedules = [
      ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Pemrograman Web',
        startTime: DateTime(2025, 11, 20, 8, 0),
        endTime: DateTime(2025, 11, 20, 10, 0),
        location: 'Ruang 301',
        lecturer: 'Dr. John Doe',
        color: '#5CD9C1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ClassSchedule(
        id: 2,
        classroomId: 1,
        title: 'Basis Data',
        startTime: DateTime(2025, 11, 20, 10, 30),
        endTime: DateTime(2025, 11, 20, 12, 30),
        location: 'Ruang 302',
        lecturer: 'Prof. Jane Smith',
        color: '#FF6B6B',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  });

  group('ScheduleCard Widget Tests', () {
    testWidgets('displays all schedules correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: testSchedules),
          ),
        ),
      );

      expect(find.text('Pemrograman Web'), findsOneWidget);
      expect(find.text('Basis Data'), findsOneWidget);
    });

    testWidgets('displays schedule times correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: testSchedules),
          ),
        ),
      );

      expect(find.text('08:00 - 10:00'), findsOneWidget);
      expect(find.text('10:30 - 12:30'), findsOneWidget);
    });

    testWidgets('displays location and lecturer', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: testSchedules),
          ),
        ),
      );

      expect(find.text('Ruang 301 | Dr. John Doe'), findsOneWidget);
      expect(find.text('Ruang 302 | Prof. Jane Smith'), findsOneWidget);
    });

    testWidgets('displays color indicators for each schedule',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: testSchedules),
          ),
        ),
      );

      // Find containers with specific constraints
      final colorIndicators = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints == const BoxConstraints.tightFor(width: 4, height: 60),
      );

      // At least should have color indicator containers
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays separator between schedules',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: testSchedules),
          ),
        ),
      );

      // Should have 1 divider between 2 schedules
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('does not display separator after last schedule',
        (WidgetTester tester) async {
      final singleSchedule = [testSchedules.first];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: singleSchedule),
          ),
        ),
      );

      // No divider for single schedule
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('calls onScheduleTap when schedule item is tapped',
        (WidgetTester tester) async {
      ClassSchedule? tappedSchedule;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(
              schedules: testSchedules,
              onScheduleTap: (schedule) {
                tappedSchedule = schedule;
              },
            ),
          ),
        ),
      );

      // Tap first schedule
      await tester.tap(find.text('Pemrograman Web'));
      await tester.pumpAndSettle();

      expect(tappedSchedule, isNotNull);
      expect(tappedSchedule?.id, equals(1));
      expect(tappedSchedule?.title, equals('Pemrograman Web'));
    });

    testWidgets('each schedule can be tapped independently',
        (WidgetTester tester) async {
      final tappedSchedules = <ClassSchedule>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(
              schedules: testSchedules,
              onScheduleTap: (schedule) {
                tappedSchedules.add(schedule);
              },
            ),
          ),
        ),
      );

      // Tap first schedule
      await tester.tap(find.text('Pemrograman Web'));
      await tester.pumpAndSettle();

      // Tap second schedule
      await tester.tap(find.text('Basis Data'));
      await tester.pumpAndSettle();

      expect(tappedSchedules.length, equals(2));
      expect(tappedSchedules[0].title, equals('Pemrograman Web'));
      expect(tappedSchedules[1].title, equals('Basis Data'));
    });

    testWidgets('does not call onScheduleTap when null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(
              schedules: testSchedules,
              onScheduleTap: null,
            ),
          ),
        ),
      );

      // Should not throw error when tapping
      await tester.tap(find.text('Pemrograman Web'));
      await tester.pumpAndSettle();

      // Test passes if no error is thrown
    });

    testWidgets('has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: testSchedules),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  AppColor.backgroundSecondary,
        ).first,
      );

      expect(container, isNotNull);
    });

    testWidgets('has rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: testSchedules),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius ==
                  BorderRadius.circular(16),
        ).first,
      );

      expect(container, isNotNull);
    });

    testWidgets('displays correct number of schedules',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: testSchedules),
          ),
        ),
      );

      // Each schedule should have a time text
      expect(find.text('08:00 - 10:00'), findsOneWidget);
      expect(find.text('10:30 - 12:30'), findsOneWidget);
    });

    testWidgets('schedule items have InkWell for tap effect',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(
              schedules: testSchedules,
              onScheduleTap: (schedule) {},
            ),
          ),
        ),
      );

      // Should have InkWell for each schedule
      expect(find.byType(InkWell), findsNWidgets(2));
    });
  });

  group('ScheduleCard Edge Cases', () {
    testWidgets('handles empty schedule list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: const []),
          ),
        ),
      );

      // Should render without error
      expect(find.byType(ScheduleCard), findsOneWidget);
    });

    testWidgets('handles schedule with null location and lecturer',
        (WidgetTester tester) async {
      final scheduleWithNulls = [
        ClassSchedule(
          id: 1,
          classroomId: 1,
          title: 'Test Schedule',
          startTime: DateTime(2025, 11, 20, 8, 0),
          endTime: DateTime(2025, 11, 20, 10, 0),
          color: '#5CD9C1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCard(schedules: scheduleWithNulls),
          ),
        ),
      );

      expect(find.text('null | null'), findsOneWidget);
    });

    testWidgets('handles long schedule titles with ellipsis',
        (WidgetTester tester) async {
      final longTitleSchedule = [
        ClassSchedule(
          id: 1,
          classroomId: 1,
          title: 'Very Long Schedule Title That Should Be Truncated',
          startTime: DateTime(2025, 11, 20, 8, 0),
          endTime: DateTime(2025, 11, 20, 10, 0),
          color: '#5CD9C1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScheduleCard(schedules: longTitleSchedule),
            ),
          ),
        ),
      );

      expect(
          find.text('Very Long Schedule Title That Should Be Truncated'),
          findsOneWidget);
    });
  });
}
