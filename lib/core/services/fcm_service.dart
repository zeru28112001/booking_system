import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('🌙 [FCM Background Message]: ${message.messageId}');
  }
}

class FCMService {
  factory FCMService() => _instance;
  FCMService._internal();
  static final FCMService _instance = FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  ApiClient? _apiClient;
  GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;

  void init({
    required ApiClient apiClient,
    GlobalKey<ScaffoldMessengerState>? messengerKey,
  }) {
    _apiClient = apiClient;
    _scaffoldMessengerKey = messengerKey;
  }

  Future<void> setupFCM() async {
    try {
      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 1. Request Notification Permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print('🔔 [FCM] Notification Permission Granted: ${settings.authorizationStatus}');
        }

        // 2. Fetch and register FCM Token
        final fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          await registerTokenWithBackend(fcmToken);
        }

        // 3. Listen to token refresh
        _firebaseMessaging.onTokenRefresh.listen(registerTokenWithBackend);

        // 4. Foreground message listener
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // 5. Background message opened app listener
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FCM Setup Error]: $e');
      }
    }
  }

  Future<void> registerTokenWithBackend(String token) async {
    if (_apiClient == null) return;
    try {
      await _apiClient!.post('/auth/fcm-token', body: {'fcmToken': token});
      if (kDebugMode) {
        print('✅ [FCM] Token registered with backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FCM Token Registration Failed]: $e');
      }
    }
  }

  Future<void> unregisterTokenWithBackend() async {
    if (_apiClient == null) return;
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _apiClient!.delete('/auth/fcm-token', body: {'fcmToken': token});
        if (kDebugMode) print('🔕 [FCM] Token unregistered from backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FCM Token Delete Failed]: $e');
      }
    }
  }

  /// Re-registers the current FCM token with the backend.
  /// Call this when the user turns push notifications back ON.
  Future<void> registerCurrentToken() async {
    if (_apiClient == null) return;
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await registerTokenWithBackend(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FCM Re-register Failed]: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📨 [FCM Foreground Message]: ${message.notification?.title}');
    }

    final notification = message.notification;
    if (notification != null && _scaffoldMessengerKey?.currentState != null) {
      _scaffoldMessengerKey!.currentState!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title ?? 'Notification',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (notification.body != null)
                      Text(
                        notification.body!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('📲 [FCM Message Tapped]: ${message.data}');
    }
    // Handle tap navigation if needed
  }
}
