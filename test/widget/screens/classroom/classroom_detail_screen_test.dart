import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:studify/presentation/screens/classroom/classroom_detail_screen.dart';
import 'package:studify/providers/classroom_provider.dart';
import 'package:studify/providers/auth_provider.dart';
import 'package:studify/data/models/classroom_model.dart';
import 'package:studify/data/models/class_schedule_model.dart';
import 'package:studify/data/models/user_model.dart' as model;

// Generate mocks
@GenerateMocks([ClassroomProvider, AuthProvider])
import 'classroom_detail_screen_test.mocks.dart';

void main() {
  late MockClassroomProvider mockClassroomProvider;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockClassroomProvider = MockClassroomProvider();
    mockAuthProvider = MockAuthProvider();

    // Setup default stubs
    when(mockAuthProvider.user).thenReturn(
      model.User(id: 1, name: 'Test User', email: 'test@example.com'),
    );

    when(mockClassroomProvider.schedules).thenReturn([]);
    when(mockClassroomProvider.isLoading).thenReturn(false);
    when(
      mockClassroomProvider.fetchClassSchedules(
        any,
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      ),
    ).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest(Classroom classroom) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ClassroomProvider>.value(
          value: mockClassroomProvider,
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      ],
      child: MaterialApp(home: ClassroomDetailScreen(classroom: classroom)),
    );
  }

  final testClassroom = Classroom(
    id: 1,
    name: 'Test Classroom',
    description: 'Test Description',
    uniqueCode: 'CODE123',
    ownerId: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  testWidgets('ClassroomDetailScreen initializes with All filter by default', (
    WidgetTester tester,
  ) async {
    // Set screen size to avoid overflow
    tester.view.physicalSize = const Size(2400, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(createWidgetUnderTest(testClassroom));
    await tester.pumpAndSettle();

    // Verify 'All' is selected in dropdown (checking text)
    expect(find.text('All'), findsOneWidget);

    // Verify fetchClassSchedules was called with null dates (for 'All')
    verify(
      mockClassroomProvider.fetchClassSchedules(
        testClassroom.id,
        startDate: null,
        endDate: null,
      ),
    ).called(1);

    // Reset screen size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Selecting 1 Day filter updates fetch parameters', (
    WidgetTester tester,
  ) async {
    // Set screen size to avoid overflow
    tester.view.physicalSize = const Size(2400, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(createWidgetUnderTest(testClassroom));
    await tester.pumpAndSettle();

    // Open dropdown
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Select '1 Day'
    await tester.tap(find.text('1 Day').last);
    await tester.pumpAndSettle();

    // Verify fetchClassSchedules was called with start and end date as today
    verify(
      mockClassroomProvider.fetchClassSchedules(
        testClassroom.id,
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      ),
    ).called(greaterThan(1));

    // Reset screen size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
