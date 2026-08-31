import 'package:kinkitchen/app/constants/api_constants.dart';
import 'package:kinkitchen/core/network/api_client.dart';
import 'package:kinkitchen/shared/models/notification_item.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // 1. Register FCM Token
  Future<void> registerFcmToken({
    required String token,
    required String deviceType, // android / ios
    required String deviceId,
  }) async {
    await _apiClient.post(
      ApiConfig.registerFcmToken,
      body: {
        'fcm_token': token,
        'device_type': deviceType,
        'device_id': deviceId,
      },
    );
  }

  // 2. Unregister Device
  Future<void> unregisterDevice(String fcmToken) async {
    await _apiClient.post(
      ApiConfig.unregisterDevice,
      body: {'fcm_token': fcmToken},
    );
  }

  // 3. Get Notifications
  Future<List<NotificationItem>> getNotifications({int limit = 20}) async {
    final response = await _apiClient.get(
      ApiConfig.notifications,
      queryParameters: {'limit': limit.toString()},
    );
    final data = response['data'] ?? response['notifications'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => NotificationItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 4. Get Unread Count
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiConfig.notificationsUnreadCount);
    final data = response['data'] ?? response;
    return data['count'] as int? ?? data['unread_count'] as int? ?? 0;
  }

  // 5. Mark Notification as Read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.post('/notifications/$notificationId/read');
    } catch (_) {
      try {
        await _apiClient.post(
          ApiConfig.markNotificationRead,
          body: {'notification_id': notificationId},
        );
      } catch (_) {}
    }
  }

  // 6. Mark All Notifications as Read
  Future<void> markAllAsRead() async {
    await _apiClient.post(ApiConfig.markAllNotificationsRead);
  }

  // 7. Send System / Event Notification (Web/Admin Panel, Restaurant, Customer)
  Future<void> sendNotification({
    int? recipientUserId,
    required String title,
    required String body,
    String? role,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      await _apiClient.post(
        ApiConfig.notifications,
        body: {
          if (recipientUserId != null) 'user_id': recipientUserId,
          'title': title,
          'body': body,
          if (role != null) 'role': role,
          if (extraData != null) 'data': extraData,
        },
      );
    } catch (_) {}
  }
}
