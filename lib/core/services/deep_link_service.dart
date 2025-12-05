import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/classroom/join_classroom_screen.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  AppLinks _appLinks = AppLinks();
  GlobalKey<NavigatorState>? _navigatorKey;

  @visibleForTesting
  set appLinks(AppLinks appLinks) {
    _appLinks = appLinks;
  }

  StreamSubscription<Uri>? _linkSubscription;

  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle initial link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    // Handle incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');

    if (uri.scheme == 'studify' && uri.host == 'join') {
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        // Navigate to Join Classroom Screen
        _navigatorKey?.currentState?.push(
          MaterialPageRoute(
            builder: (context) => JoinClassroomScreen(initialCode: code),
          ),
        );
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
