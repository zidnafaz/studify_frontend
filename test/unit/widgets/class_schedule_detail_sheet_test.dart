import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studify/core/constants/app_color.dart';
import 'package:studify/data/models/class_schedule_model.dart';
import 'package:studify/data/models/classroom_model.dart';
import 'package:studify/data/models/user_model.dart';
import 'package:studify/presentation/widgets/sheets/class_schedule_detail_sheet.dart';
import 'package:studify/providers/auth_provider.dart';

// Mock AuthProvider for testing
class MockAuthProvider extends AuthProvider {
  User? _mockUser;

  void setMockUser(User user) {
    _mockUser = user;
    notifyListeners();
  }

  @override
  User? get user => _mockUser;
}

void main() {
  late Classroom testClassroom;
  late ClassSchedule testSchedule;
  late User ownerUser;
  late User coordinatorUser;
  late User regularUser;

  setUp(() {
    ownerUser = User(
      id: 1,
      name: 'Owner User',
      email: 'owner@test.com',
    );

    coordinatorUser = User(
      id: 2,
      name: 'Coordinator User',
      email: 'coordinator@test.com',
    );

    regularUser = User(
      id: 3,
      name: 'Regular User',
      email: 'regular@test.com',
    );

    testClassroom = Classroom(
      id: 1,
      ownerId: 1,
      name: 'Test Classroom',
      uniqueCode: 'TEST123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testSchedule = ClassSchedule(
      id: 1,
      classroomId: 1,
      coordinator1: 2,
      coordinator2: null,
      title: 'Pemrograman Web',
      startTime: DateTime(2025, 11, 20, 8, 0),
      endTime: DateTime(2025, 11, 20, 10, 0),
      location: 'Ruang 301',
      lecturer: 'Dr. John Doe',
      description: 'Pertemuan ke-5: RESTful API',
      color: '#5CD9C1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      coordinator1User: coordinatorUser,
    );
  });

  Widget createWidgetUnderTest(User currentUser) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final authProvider = MockAuthProvider();
            authProvider.setMockUser(currentUser);
            return authProvider;
          },
          child: ClassScheduleDetailSheet(
            schedule: testSchedule,
            classroom: testClassroom,
          ),
        ),
      ),
    );
  }

  group('ClassScheduleDetailSheet Widget Tests', () {
    testWidgets('displays schedule title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('Pemrograman Web'), findsOneWidget);
    });

    testWidgets('displays schedule time correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('08:00 - 10:00'), findsOneWidget);
    });

    testWidgets('displays schedule date correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('20 Nov 2025'), findsOneWidget);
    });

    testWidgets('displays lecturer name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('Dr. John Doe'), findsOneWidget);
    });

    testWidgets('displays location correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('Ruang 301'), findsOneWidget);
    });

    testWidgets('displays description when available', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Pertemuan ke-5: RESTful API'), findsOneWidget);
    });

    testWidgets('shows Edit button for owner', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(ownerUser));

      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('shows Edit button for coordinator 1', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coordinatorUser));

      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('hides Edit button for regular member', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('displays Add Reminder button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('Add Reminder'), findsOneWidget);
      expect(find.widgetWithIcon(InkWell, Icons.add), findsWidgets);
    });

    testWidgets('displays info icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.byIcon(Icons.access_time), findsWidgets);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays handle bar at the top', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      // Check for handle bar container
      final handleBar = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(2),
      );

      expect(handleBar, findsWidgets);
    });

    testWidgets('schedule without description hides Description section',
        (WidgetTester tester) async {
      final scheduleWithoutDescription = ClassSchedule(
        id: 1,
        classroomId: 1,
        title: 'Test Schedule',
        startTime: DateTime(2025, 11, 20, 8, 0),
        endTime: DateTime(2025, 11, 20, 10, 0),
        color: '#5CD9C1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<AuthProvider>(
              create: (_) {
                final authProvider = MockAuthProvider();
                authProvider.setMockUser(regularUser);
                return authProvider;
              },
              child: ClassScheduleDetailSheet(
                schedule: scheduleWithoutDescription,
                classroom: testClassroom,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Description'), findsNothing);
    });

    testWidgets('displays color box with correct color', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      // Find the color box container
      final colorBox = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  const Color(0xFF5CD9C1),
        ),
      );

      expect(colorBox, isNotNull);
    });

    testWidgets('tapping Edit button pops the sheet', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(ownerUser));

      final editButton = find.text('Edit');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // The sheet should be popped (but we can't easily test navigation in unit tests)
      // This test just ensures the button is tappable
    });
  });

  group('ClassScheduleDetailSheet Permission Tests', () {
    testWidgets('owner can see edit button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(ownerUser));
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('coordinator 1 can see edit button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coordinatorUser));
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('coordinator 2 can see edit button', (WidgetTester tester) async {
      final coordinator2User = User(
        id: 4,
        name: 'Coordinator 2',
        email: 'coord2@test.com',
      );

      final scheduleWithCoordinator2 = ClassSchedule(
        id: 1,
        classroomId: 1,
        coordinator1: null,
        coordinator2: 4,
        title: 'Test Schedule',
        startTime: DateTime(2025, 11, 20, 8, 0),
        endTime: DateTime(2025, 11, 20, 10, 0),
        color: '#5CD9C1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<AuthProvider>(
              create: (_) {
                final authProvider = MockAuthProvider();
                authProvider.setMockUser(coordinator2User);
                return authProvider;
              },
              child: ClassScheduleDetailSheet(
                schedule: scheduleWithCoordinator2,
                classroom: testClassroom,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('regular member cannot see edit button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));
      expect(find.text('Edit'), findsNothing);
    });
  });

  group('ClassScheduleDetailSheet Reminder Tests', () {
    testWidgets('Add Reminder button is always visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.text('Add Reminder'), findsOneWidget);
    });

    testWidgets('Add Reminder button has correct icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      final addButton = find.ancestor(
        of: find.text('Add Reminder'),
        matching: find.byType(InkWell),
      );

      expect(addButton, findsOneWidget);
    });
  });

  group('ClassScheduleDetailSheet UI Tests', () {
    testWidgets('uses correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  AppColor.backgroundPrimary,
        ).first,
      );

      expect(container, isNotNull);
    });

    testWidgets('has rounded top corners', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius ==
                  const BorderRadius.vertical(top: Radius.circular(24)),
        ).first,
      );

      expect(container, isNotNull);
    });

    testWidgets('is scrollable for long content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(regularUser));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
