import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:studify/presentation/screens/home/home_screen.dart';
import 'package:studify/providers/combined_schedule_provider.dart';
import 'package:studify/providers/auth_provider.dart';
import 'package:studify/providers/classroom_provider.dart';
import 'package:studify/providers/notification_provider.dart';
import 'package:studify/providers/personal_schedule_provider.dart';
import 'package:studify/data/models/classroom_model.dart';
import 'package:studify/data/models/class_schedule_model.dart';
import 'package:studify/data/models/notification_model.dart';
import 'package:studify/data/models/combined_schedule_model.dart';
import 'package:studify/data/services/device_token_service.dart';
import 'package:studify/data/models/user_model.dart' as model;

// Generate mocks
@GenerateMocks([
  CombinedScheduleProvider,
  AuthProvider,
  ClassroomProvider,
  NotificationProvider,
  PersonalScheduleProvider,
  DeviceTokenService,
])
import 'home_screen_test.mocks.dart';

void main() {
  late MockCombinedScheduleProvider mockScheduleProvider;
  late MockAuthProvider mockAuthProvider;
  late MockClassroomProvider mockClassroomProvider;
  late MockNotificationProvider mockNotificationProvider;
  late MockPersonalScheduleProvider mockPersonalScheduleProvider;
  late MockDeviceTokenService mockDeviceTokenService;

  setUp(() {
    mockScheduleProvider = MockCombinedScheduleProvider();
    mockAuthProvider = MockAuthProvider();
    mockClassroomProvider = MockClassroomProvider();
    mockNotificationProvider = MockNotificationProvider();
    mockPersonalScheduleProvider = MockPersonalScheduleProvider();
    mockDeviceTokenService = MockDeviceTokenService();

    // Setup default stubs
    when(mockAuthProvider.user).thenReturn(
      model.User(id: 1, name: 'Test User', email: 'test@example.com'),
    );

    when(mockScheduleProvider.schedules).thenReturn([]);
    when(mockScheduleProvider.isLoading).thenReturn(false);
    when(mockScheduleProvider.errorMessage).thenReturn(null);
    when(mockScheduleProvider.availableSources).thenReturn([]);
    when(
      mockScheduleProvider.fetchCombinedSchedules(
        source: anyNamed('source'),
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      ),
    ).thenAnswer((_) async {});

    when(mockClassroomProvider.fetchClassrooms()).thenAnswer((_) async {});
    when(
      mockNotificationProvider.fetchNotifications(),
    ).thenAnswer((_) async {});
    when(mockNotificationProvider.unreadCount).thenReturn(0);
    when(
      mockPersonalScheduleProvider.fetchPersonalSchedules(),
    ).thenAnswer((_) async {});
    when(mockDeviceTokenService.syncDeviceToken()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CombinedScheduleProvider>.value(
          value: mockScheduleProvider,
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ClassroomProvider>.value(
          value: mockClassroomProvider,
        ),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: mockNotificationProvider,
        ),
        ChangeNotifierProvider<PersonalScheduleProvider>.value(
          value: mockPersonalScheduleProvider,
        ),
        Provider<DeviceTokenService>.value(value: mockDeviceTokenService),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('HomeScreen initializes with All filter by default', (
    WidgetTester tester,
  ) async {
    // Set screen size to avoid overflow
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for microtasks

    // Verify 'All' is selected in dropdown (checking text)
    expect(find.text('All'), findsOneWidget);

    // Verify fetchCombinedSchedules was called with null dates (for 'All')
    verify(
      mockScheduleProvider.fetchCombinedSchedules(
        source: null,
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

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Open dropdown
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Select '1 Day'
    await tester.tap(find.text('1 Day').last);
    await tester.pumpAndSettle();

    // Verify fetchCombinedSchedules was called with start and end date as today
    verify(
      mockScheduleProvider.fetchCombinedSchedules(
        source: null,
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      ),
    ).called(greaterThan(1));

    // Reset screen size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
