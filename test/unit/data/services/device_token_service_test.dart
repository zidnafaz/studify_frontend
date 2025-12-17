import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:studify/data/services/device_token_service.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late DeviceTokenService deviceTokenService;
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockDioClient mockDioClient;

  setUp(() {
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockDioClient = MockDioClient();
    deviceTokenService = DeviceTokenService(
      firebaseMessaging: mockFirebaseMessaging,
      dioClient: mockDioClient,
    );
  });

  group('DeviceTokenService', () {
    test('getDeviceToken returns token from FirebaseMessaging', () async {
      // Arrange
      when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => 'test_token');

      // Act
      final token = await deviceTokenService.getDeviceToken();

      // Assert
      expect(token, 'test_token');
      verify(mockFirebaseMessaging.getToken()).called(1);
    });

    test('getDeviceToken returns null on error', () async {
      // Arrange
      when(mockFirebaseMessaging.getToken()).thenThrow(Exception('Error'));

      // Act
      final token = await deviceTokenService.getDeviceToken();

      // Assert
      expect(token, null);
    });

    test('requestPermission calls FirebaseMessaging requestPermission', () async {
      // Arrange
      when(mockFirebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      )).thenAnswer((_) async => const NotificationSettings(
            authorizationStatus: AuthorizationStatus.authorized,
            alert: AppleNotificationSetting.enabled,
            announcement: AppleNotificationSetting.enabled,
            badge: AppleNotificationSetting.enabled,
            carPlay: AppleNotificationSetting.enabled,
            lockScreen: AppleNotificationSetting.enabled,
            notificationCenter: AppleNotificationSetting.enabled,
            showPreviews: AppleShowPreviewSetting.always,
            sound: AppleNotificationSetting.enabled,
            timeSensitive: AppleNotificationSetting.enabled,
            criticalAlert: AppleNotificationSetting.enabled,
            providesAppNotificationSettings: AppleNotificationSetting.enabled,
          ));

      // Act
      await deviceTokenService.requestPermission();

      // Assert
      verify(mockFirebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      )).called(1);
    });
  });
}
