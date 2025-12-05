import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:studify/core/http/dio_client.dart';

class DeviceTokenService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DioClient _dioClient = DioClient();

  Future<String?> getDeviceToken() async {
    try {
      if (kIsWeb) {
        // For web, you might need a VAPID key
        return await _firebaseMessaging.getToken();
      } else {
        return await _firebaseMessaging.getToken();
      }
    } catch (e) {
      debugPrint('Error getting device token: $e');
      return null;
    }
  }

  Future<void> syncDeviceToken() async {
    try {
      // Request permission first (especially for iOS)
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(alert: true, badge: true, sound: true);

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await getDeviceToken();
        if (token != null) {
          await _sendTokenToBackend(token);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen(_sendTokenToBackend);
      }
    } catch (e) {
      debugPrint('Error syncing device token: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final platform = kIsWeb
          ? 'web'
          : (Platform.isAndroid ? 'android' : 'ios');

      await _dioClient.post(
        '/api/device-tokens',
        data: {'token': token, 'platform': platform},
      );
      debugPrint('Device token synced successfully');
    } catch (e) {
      debugPrint('Failed to sync device token: $e');
    }
  }
}
