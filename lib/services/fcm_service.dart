import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient = ApiClient();
  final _secureStorage = const FlutterSecureStorage();

  Future<void> initialize() async {
    // 1. Request notification permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted notification permission');
      }
    }

    // 2. Setup token refresh listener
    _messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
      await syncTokenWithBackend(newToken);
    });

    // Get current token on startup and sync if authenticated
    String? token = await getFcmToken();
    if (token != null) {
      await syncTokenWithBackend(token);
    }
  }

  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  Future<void> syncTokenWithBackend(String fcmToken) async {
    // Check if user is authenticated (we have a Sanctum token in secure storage)
    final sanctumToken = await _secureStorage.read(key: 'auth_token');
    if (sanctumToken == null) {
      // User is not logged in yet, we don't sync. Token will be sent during login.
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final deviceType = Platform.isAndroid ? 'android' : 'ios';
    
    // Get unique device ID
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = 'device_${deviceType}_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceId);
    }

    try {
      await _apiClient.post(
        '/device/fcm-token',
        body: {
          'device_type': deviceType,
          'device_id': deviceId,
          'fcm_token': fcmToken,
        },
      );
      if (kDebugMode) {
        print('FCM Token successfully synced with Laravel backend.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync FCM Token with backend: $e');
      }
    }
  }
}
