import 'package:flutter/material.dart';
import 'package:kinkitchen/shared/models/notification_item.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/modules/restaurant/restaurant_state_provider.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isRestaurant;
  const NotificationsScreen({super.key, this.isRestaurant = false});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    try {
      if (widget.isRestaurant) {
        final state = RestaurantStateScope.of(context);
        await state.fetchNotifications();
      } else {
        final state = TiffinStateScope.of(context);
        await state.fetchNotifications();
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFFF5E00);
    List<NotificationItem> notifications = [];
    int unreadCount = 0;

    if (widget.isRestaurant) {
      final state = RestaurantStateScope.of(context);
      notifications = state.notifications;
      unreadCount = state.unreadNotificationCount;
    } else {
      final state = TiffinStateScope.of(context);
      notifications = state.notifications;
      unreadCount = state.unreadNotificationCount;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty && unreadCount > 0)
            TextButton(
              onPressed: () async {
                if (widget.isRestaurant) {
                  await RestaurantStateScope.of(context).markAllNotificationsAsRead();
                } else {
                  await TiffinStateScope.of(context).markAllNotificationsAsRead();
                }
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: brandOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: brandOrange,
        onRefresh: _loadNotifications,
        child: notifications.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: brandOrange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_outlined,
                            size: 40,
                            color: brandOrange,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Notifications Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We\'ll notify you when orders, subscriptions,\nor status updates arrive.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return _buildNotificationCard(context, item, brandOrange);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item, Color brandOrange) {
    return GestureDetector(
      onTap: () {
        if (!item.isRead) {
          if (widget.isRestaurant) {
            RestaurantStateScope.of(context).markNotificationAsRead(item.id);
          } else {
            TiffinStateScope.of(context).markNotificationAsRead(item.id);
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : brandOrange.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead ? const Color(0xFFE5E7EB) : brandOrange.withValues(alpha: 0.3),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.isRead
                    ? const Color(0xFFF3F4F6)
                    : brandOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(item.title),
                color: item.isRead ? const Color(0xFF6B7280) : brandOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title.isNotEmpty ? item.title : 'Notification',
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: brandOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.3,
                    ),
                  ),
                  if (item.createdAt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('order')) {
      return Icons.shopping_bag_outlined;
    } else if (lower.contains('subscription') || lower.contains('plan')) {
      return Icons.card_membership_outlined;
    } else if (lower.contains('status')) {
      return Icons.local_shipping_outlined;
    }
    return Icons.notifications_outlined;
  }

  String _formatDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(parsed);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${parsed.day}/${parsed.month}/${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
