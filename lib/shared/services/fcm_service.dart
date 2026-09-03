import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kinkitchen/core/network/api_client.dart';
import 'package:kinkitchen/app/constants/api_constants.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient = ApiClient();
  final _secureStorage = const FlutterSecureStorage();

  bool _isInitialized = false;
  String? _cachedToken;
  String? _lastSyncedToken;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('FCM: initialization skipped - already initialized');
      return;
    }
    _isInitialized = true;
    debugPrint('FCM: initialization started');

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

    // Set foreground notification options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup token refresh listener
    _messaging.onTokenRefresh.listen((newToken) async {
      _cachedToken = newToken;
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
      await syncTokenWithBackend(newToken);
    });

    // 3. Setup Foreground Message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received FCM foreground message: ${message.notification?.title} - ${message.notification?.body}');
      }
      final navContext = NavigationService.navigatorKey.currentContext;
      if (navContext != null && message.notification != null) {
        ScaffoldMessenger.of(navContext).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.notification!.title ?? 'Notification', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(message.notification!.body ?? '', style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: const Color(0xFFFF5E00),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    // 4. Setup Background / Opened App listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('FCM notification opened app: ${message.data}');
      }
      _handleNotificationTap(message);
    });

    // 5. Check if app was opened from a terminated notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print('FCM initial message: ${message.data}');
        }
        _handleNotificationTap(message);
      }
    });

    // Get current token on startup and sync if authenticated
    String? token = await getFcmToken();
    if (token != null) {
      await syncTokenWithBackend(token);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type']?.toString().toLowerCase() ?? '';
    final orderIdRaw = message.data['order_id'] ?? message.data['id'];

    if (orderIdRaw != null) {
      final orderId = int.tryParse(orderIdRaw.toString());
      if (orderId != null) {
        NavigationService.navigatorKey.currentState?.pushNamed('/orders/$orderId');
        return;
      }
    }

    if (type.contains('new_order') || type.contains('receipt')) {
      NavigationService.navigatorKey.currentState?.pushNamed('/restaurant-notifications');
    } else {
      NavigationService.navigatorKey.currentState?.pushNamed('/notifications');
    }
  }

  Future<String?> getFcmToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedToken != null) {
      return _cachedToken;
    }
    try {
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (kDebugMode) {
          print('iOS APNS Token: $apnsToken');
        }
        // Apple iOS Simulator returns fake APNs token '66616B652D...' ("fake-apns-token-for-simulator")
        // Firebase servers reject fake APNs token. Provide fallback token for simulator.
        if (apnsToken != null && apnsToken.toLowerCase().contains('66616b652d')) {
          const simToken = 'ios_sim_fcm_token_66616b652d';
          _cachedToken = simToken;
          if (kDebugMode) {
            print('FCM Token (Simulator Fallback): $simToken');
          }
          return simToken;
        }
      }
      final token = await _messaging.getToken();
      if (token != null) {
        _cachedToken = token;
      }
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token (Simulator Fallback applied): $e');
      }
      _cachedToken = 'ios_sim_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
      return _cachedToken;
    }
  }

  Future<void> syncTokenWithBackend(String fcmToken) async {
    // Avoid duplicate sync for the same token
    if (_lastSyncedToken == fcmToken) {
      return;
    }

    // Check if user is authenticated
    final sanctumToken = await _secureStorage.read(key: 'auth_token');
    if (sanctumToken == null) {
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

    final payload = {
      'device_type': deviceType,
      'device_id': deviceId,
      'fcm_token': fcmToken,
    };

    try {
      await _apiClient.post(ApiConfig.registerFcmToken, body: payload);
      _lastSyncedToken = fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('Ignored sync FCM Token error: $e');
      }
    }
  }
}
