import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:studify/data/services/device_token_service.dart';

class FakeDeviceTokenService implements DeviceTokenService {
  @override
  Future<String?> getDeviceToken() async {
    return 'fake_device_token';
  }

  @override
  Future<void> syncDeviceToken() async {
    // No-op for testing
  }

  @override
  Future<NotificationSettings> requestPermission() async {
    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.authorized,
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.enabled,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.enabled,
      criticalAlert: AppleNotificationSetting.enabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      sound: AppleNotificationSetting.enabled,
      timeSensitive: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.enabled,
    );
  }
}
