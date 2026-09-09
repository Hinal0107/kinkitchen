import 'package:flutter/material.dart';
import 'package:kinkitchen/shared/models/order.dart';

class LiveOrderStepper extends StatefulWidget {
  final String orderStatus;
  final String? deliveryStatus;
  final List<OrderTrackingTimelineStep> timeline;

  const LiveOrderStepper({
    super.key,
    required this.orderStatus,
    this.deliveryStatus,
    this.timeline = const [],
  });

  @override
  State<LiveOrderStepper> createState() => _LiveOrderStepperState();
}

class _LiveOrderStepperState extends State<LiveOrderStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  static const List<Map<String, dynamic>> _steps = [
    {
      'key': 'PLACED',
      'title': 'Order Placed',
      'subtitle': 'Waiting for restaurant confirmation',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'key': 'CONFIRMED',
      'title': 'Confirmed',
      'subtitle': 'Restaurant accepted your order',
      'icon': Icons.check_circle_outline,
    },
    {
      'key': 'PREPARING',
      'title': 'Preparing',
      'subtitle': 'Kitchen is cooking your meal',
      'icon': Icons.soup_kitchen_outlined,
    },
    {
      'key': 'READY',
      'title': 'Ready',
      'subtitle': 'Packed & ready for pickup/delivery',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'key': 'OUT_FOR_DELIVERY',
      'title': 'Out for Delivery',
      'subtitle': 'Rider is on the way to you',
      'icon': Icons.two_wheeler_outlined,
    },
    {
      'key': 'DELIVERED',
      'title': 'Delivered',
      'subtitle': 'Enjoy your meal!',
      'icon': Icons.task_alt_outlined,
    },
  ];

  int _getCurrentStepIndex() {
    final oStat = widget.orderStatus.toUpperCase();
    final dStat = widget.deliveryStatus?.toUpperCase() ?? '';

    if (dStat == 'DELIVERED' || oStat == 'DELIVERED' || oStat == 'COMPLETED') {
      return 5;
    }
    if (dStat == 'OUT_FOR_DELIVERY' || oStat == 'OUT_FOR_DELIVERY') {
      return 4;
    }
    if (oStat == 'READY') {
      return 3;
    }
    if (oStat == 'PREPARING') {
      return 2;
    }
    if (oStat == 'CONFIRMED') {
      return 1;
    }
    return 0; // PENDING_PAYMENT / PENDING / PLACED
  }

  String? _getStepTimestamp(String stepKey) {
    if (widget.timeline.isEmpty) return null;
    final match = widget.timeline.where(
      (t) => t.status.toUpperCase() == stepKey.toUpperCase(),
    );
    if (match.isNotEmpty) {
      return match.last.timestamp;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _getCurrentStepIndex();
    const Color brandOrange = Color(0xFFFF5E00);
    const Color activeGreen = Color(0xFF00A859);
    const Color grayColor = Color(0xFF9CA3AF);

    final bool isCancelled = widget.orderStatus.toUpperCase() == 'CANCELLED' || widget.orderStatus.toUpperCase() == 'REJECTED';

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ${widget.orderStatus.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'This order has been cancelled or rejected.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE ORDER TRACKING',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Color(0xFF6B7280),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brandOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: brandOrange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: brandOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stepper Items Vertical List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              final stepKey = step['key'] as String;
              final isPassed = index <= activeIndex;
              final isCurrent = index == activeIndex;
              final isLast = index == _steps.length - 1;
              final timestamp = _getStepTimestamp(stepKey);

              final Color stepColor = isCurrent
                  ? brandOrange
                  : (isPassed ? activeGreen : grayColor);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Vertical Line Column
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isCurrent)
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: brandOrange.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? brandOrange
                                  : (isPassed ? activeGreen.withValues(alpha: 0.12) : const Color(0xFFF3F4F6)),
                              border: Border.all(
                                color: stepColor,
                                width: isCurrent ? 2 : 1.5,
                              ),
                            ),
                            child: Icon(
                              step['icon'] as IconData,
                              size: 16,
                              color: isCurrent
                                  ? Colors.white
                                  : (isPassed ? activeGreen : grayColor),
                            ),
                          ),
                        ],
                      ),
                      if (!isLast)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 2,
                          height: 36,
                          color: isPassed && index < activeIndex
                              ? activeGreen
                              : const Color(0xFFE5E7EB),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Content Column
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step['title'] as String,
                                style: TextStyle(
                                  fontWeight: isCurrent || isPassed ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 14,
                                  color: isCurrent
                                      ? brandOrange
                                      : (isPassed ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF)),
                                ),
                              ),
                              if (timestamp != null && timestamp.isNotEmpty)
                                Text(
                                  timestamp,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrent
                                  ? const Color(0xFF4B5563)
                                  : (isPassed ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
