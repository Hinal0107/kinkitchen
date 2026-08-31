import 'package:flutter_test/flutter_test.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/modules/restaurant/restaurant_state_provider.dart';
import 'package:kinkitchen/shared/models/notification_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Model & Flow Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('NotificationItem parsing handles both bool and int is_read fields', () {
      final json1 = {
        'id': 1,
        'user_id': 10,
        'title': 'Order Placed',
        'body': 'Your order #1001 is placed.',
        'is_read': 0,
        'created_at': '2026-08-31T10:00:00Z',
      };

      final item1 = NotificationItem.fromJson(json1);
      expect(item1.id, 1);
      expect(item1.title, 'Order Placed');
      expect(item1.isRead, false);

      final json2 = {
        'id': 2,
        'user_id': 10,
        'title': 'Order Delivered',
        'body': 'Your order has been delivered.',
        'is_read': 1,
        'created_at': '2026-08-31T10:30:00Z',
      };

      final item2 = NotificationItem.fromJson(json2);
      expect(item2.id, 2);
      expect(item2.isRead, true);

      final json3 = {
        'id': 3,
        'user_id': 10,
        'title': 'Subscription Active',
        'body': 'Subscription activated.',
        'is_read': true,
        'created_at': '2026-08-31T10:35:00Z',
      };

      final item3 = NotificationItem.fromJson(json3);
      expect(item3.isRead, true);
    });

    test('TiffinStateProvider notification state management', () async {
      final provider = TiffinStateProvider();
      provider.notifications = [
        NotificationItem(
          id: 1,
          userId: 5,
          title: 'Order Status',
          body: 'Preparing your meal',
          isRead: false,
          createdAt: '2026-08-31T10:00:00Z',
        ),
        NotificationItem(
          id: 2,
          userId: 5,
          title: 'Subscription',
          body: 'Subscription renewed',
          isRead: false,
          createdAt: '2026-08-31T10:15:00Z',
        ),
      ];
      provider.unreadNotificationCount = 2;

      expect(provider.unreadNotificationCount, 2);

      await provider.markNotificationAsRead(1);
      expect(provider.unreadNotificationCount, 1);
      expect(provider.notifications.firstWhere((n) => n.id == 1).isRead, true);

      await provider.markAllNotificationsAsRead();
      expect(provider.unreadNotificationCount, 0);
      expect(provider.notifications.every((n) => n.isRead), true);
    });

    test('RestaurantStateProvider notification state management', () async {
      final provider = RestaurantStateProvider();
      provider.notifications = [
        NotificationItem(
          id: 10,
          userId: 2,
          title: 'New Order',
          body: 'New order received #505',
          isRead: false,
          createdAt: '2026-08-31T10:20:00Z',
        ),
      ];
      provider.unreadNotificationCount = 1;

      expect(provider.unreadNotificationCount, 1);

      await provider.markNotificationAsRead(10);
      expect(provider.unreadNotificationCount, 0);
      expect(provider.notifications.first.isRead, true);
    });
  });
}
