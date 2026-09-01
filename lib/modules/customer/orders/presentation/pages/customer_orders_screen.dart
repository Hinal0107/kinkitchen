import 'package:flutter/material.dart';
import 'package:kinkitchen/core/widgets/food_image.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/shared/models/order.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = TiffinStateScope.of(context);
    if (!_hasFetched) {
      _hasFetched = true;
      state.fetchCustomerOrders();
    }
  }

  Color _getStatusColor(String status, String? deliveryStatus) {
    final dStat = deliveryStatus?.toUpperCase() ?? '';
    final oStat = status.toUpperCase();

    if (dStat == 'DELIVERED' || oStat == 'COMPLETED' || oStat == 'DELIVERED') return const Color(0xFF00A859);
    if (dStat == 'OUT_FOR_DELIVERY' || oStat == 'OUT_FOR_DELIVERY') return const Color(0xFF7C3AED);
    if (oStat == 'READY') return const Color(0xFF059669);
    if (oStat == 'PREPARING') return const Color(0xFF0284C7);
    if (oStat == 'CONFIRMED') return const Color(0xFF2563EB);
    if (oStat == 'REJECTED' || oStat == 'CANCELLED') return Colors.red;
    return const Color(0xFFD97706);
  }

  String _getStatusText(Order order) {
    final dStat = order.deliveryStatus?.toUpperCase() ?? '';
    final oStat = order.status.toUpperCase();

    if (dStat == 'DELIVERED' || oStat == 'COMPLETED' || oStat == 'DELIVERED') return 'DELIVERED';
    if (dStat == 'OUT_FOR_DELIVERY' || oStat == 'OUT_FOR_DELIVERY') return 'OUT FOR DELIVERY';
    if (oStat == 'READY') return 'READY FOR DELIVERY';
    if (oStat == 'PREPARING') return 'PREPARING';
    if (oStat == 'CONFIRMED') return 'CONFIRMED';
    if (oStat == 'REJECTED') return 'REJECTED';
    if (oStat == 'CANCELLED') return 'CANCELLED';
    return 'PENDING';
  }

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color brandOrange = Color(0xFFFF5E00);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4B5563)),
            onPressed: () => state.fetchCustomerOrders(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await state.fetchCustomerOrders(),
        color: brandOrange,
        child: state.isLoading && state.customerOrders.isEmpty
            ? const Center(child: CircularProgressIndicator(color: brandOrange))
            : state.customerOrders.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'No Orders Placed Yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'When you order meal plans or add-ons, your active orders will show here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.customerOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final order = state.customerOrders[index];
                      return _buildOrderCard(context, state, order);
                    },
                  ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, TiffinStateProvider state, Order order) {
    const Color brandOrange = Color(0xFFFF5E00);
    final statusColor = _getStatusColor(order.status, order.deliveryStatus);
    final statusText = _getStatusText(order);
    final bool isOutForDelivery = (order.deliveryStatus?.toUpperCase() == 'OUT_FOR_DELIVERY');
    final bool isDelivered = (order.deliveryStatus?.toUpperCase() == 'DELIVERED' || order.status.toUpperCase() == 'COMPLETED');

    return Container(
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
          // Order Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.createdAt.isNotEmpty ? order.createdAt : 'Just now',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDelivered) ...[
                        const Icon(Icons.check_circle, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        statusText,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Items
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        FoodImage(
                          title: item.title,
                          imageUrl: item.imageUrl,
                          width: 42,
                          height: 42,
                          borderRadius: 8,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1F2937)),
                              ),
                              Text(
                                'Qty: ${item.quantity} x £${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '£${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1F2937)),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(height: 20),

                // Itemized Payment Structure (matching Image 15 & 16)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          Text('£${order.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                        ],
                      ),
                      if (order.subscriptionAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subscription Covered', style: TextStyle(fontSize: 12, color: Color(0xFF00A859), fontWeight: FontWeight.bold)),
                            Text('-£${order.subscriptionAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF00A859), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                      if (order.addonAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Add-ons (Paid separately)', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                            Text('£${order.addonAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax & GST', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          Text('£${order.tax.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          Text(
                            order.deliveryFee > 0 ? '£${order.deliveryFee.toStringAsFixed(2)}' : 'FREE',
                            style: TextStyle(fontSize: 12, color: order.deliveryFee > 0 ? const Color(0xFF374151) : const Color(0xFF00A859), fontWeight: order.deliveryFee > 0 ? FontWeight.normal : FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Order Value', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          Text('£${order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Customer Paid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                          Text(
                            '£${order.paidAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: brandOrange),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Delivery Address
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                      ),
                    ),
                  ],
                ),

                // OTP REVEAL & CONFIRMATION SECTION FOR OUT_FOR_DELIVERY
                if (isOutForDelivery) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD8A8)),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_shipping, color: brandOrange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Out for Delivery!',
                              style: TextStyle(fontWeight: FontWeight.bold, color: brandOrange, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.otpRevealed
                              ? 'Provide this 4-digit Delivery OTP to the delivery person:'
                              : 'Click Confirm Received when your delivery person arrives to reveal your OTP.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                        ),
                        const SizedBox(height: 10),

                        if (order.otpRevealed && order.deliveryOtp != null) ...[
                          // Display revealed OTP in large digits
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: brandOrange, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_clock_outlined, color: brandOrange, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'OTP: ${order.deliveryOtp}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    color: brandOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Confirm Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandOrange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                              label: const Text(
                                'Confirm Received & Show OTP',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: () async {
                                try {
                                  await state.confirmOrderReceipt(order.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Order receipt confirmed! OTP revealed to restaurant.'),
                                        backgroundColor: Color(0xFF00A859),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // DELIVERED TAG
                if (isDelivered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF00A859), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Order Delivered Successfully (OTP Verified)',
                            style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
