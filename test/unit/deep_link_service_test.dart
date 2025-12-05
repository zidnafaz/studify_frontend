import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studify/core/services/deep_link_service.dart';
import 'package:studify/presentation/screens/classroom/join_classroom_screen.dart';

// Generate mocks
@GenerateMocks([AppLinks])
@GenerateNiceMocks([MockSpec<NavigatorObserver>()])
import 'deep_link_service_test.mocks.dart';

void main() {
  late DeepLinkService deepLinkService;
  late MockAppLinks mockAppLinks;
  late MockNavigatorObserver mockNavigatorObserver;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    deepLinkService = DeepLinkService();
    mockAppLinks = MockAppLinks();
    mockNavigatorObserver = MockNavigatorObserver();
    navigatorKey = GlobalKey<NavigatorState>();

    // Inject mock
    deepLinkService.appLinks = mockAppLinks;
  });

  testWidgets(
    'DeepLinkService navigates to JoinClassroomScreen on valid link',
    (WidgetTester tester) async {
      // Arrange
      final uri = Uri.parse('studify://join?code=TESTCODE');
      final streamController = StreamController<Uri>();

      when(mockAppLinks.getInitialLink()).thenAnswer((_) async => null);
      when(
        mockAppLinks.uriLinkStream,
      ).thenAnswer((_) => streamController.stream);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Container(),
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      // Act
      deepLinkService.init(navigatorKey);
      streamController.add(uri);

      await tester.pumpAndSettle();

      // Assert
      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.byType(JoinClassroomScreen), findsOneWidget);

      streamController.close();
    },
  );
}
