import 'package:flutter/material.dart';
import 'package:kinkitchen/modules/restaurant/restaurant_state_provider.dart';
import 'package:kinkitchen/modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';
import 'package:kinkitchen/shared/models/order.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasFetchedInitialData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = RestaurantStateScope.of(context);
    if (!_hasFetchedInitialData && !state.isLoading && state.errorMessage == null) {
      _hasFetchedInitialData = true;
      Future.microtask(() => state.fetchOrders());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = RestaurantStateScope.of(context);
    const Color merchantGreen = Color(0xFF00A859);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Customer Orders',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: merchantGreen,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: merchantGreen,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All Orders'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4B5563)),
            onPressed: () => state.fetchOrders(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: merchantGreen))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(state, _filterOrders(state.orders, 'active')),
                _buildOrdersList(state, _filterOrders(state.orders, 'completed')),
                _buildOrdersList(state, state.orders),
              ],
            ),
    );
  }

  List<Order> _filterOrders(List<Order> orders, String type) {
    if (type == 'completed') {
      return orders.where((o) => o.status == 'DELIVERED' || o.status == 'REJECTED' || o.status == 'CANCELLED').toList();
    } else if (type == 'active') {
      return orders.where((o) => o.status != 'DELIVERED' && o.status != 'REJECTED' && o.status != 'CANCELLED').toList();
    }
    return orders;
  }

  Widget _buildOrdersList(RestaurantStateProvider state, List<Order> ordersList) {
    const Color merchantGreen = Color(0xFF00A859);

    if (ordersList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFD1D5DB)),
              SizedBox(height: 16),
              Text(
                'No Orders Found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              SizedBox(height: 8),
              Text(
                'There are no customer orders matching this category.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: ordersList.length,
      itemBuilder: (context, index) {
        final order = ordersList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Order # & Status badge)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER #${order.orderNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Payment: ${order.paymentStatus}',
                            style: TextStyle(
                              fontSize: 11,
                              color: order.paymentStatus == 'PAID' ? merchantGreen : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),

                // Customer Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 8),
                          Text(
                            order.customerName.isEmpty ? 'Guest Customer' : order.customerName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151)),
                          ),
                        ],
                      ),
                      if (order.customerPhone.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 8),
                            Text(
                              order.customerPhone,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.deliveryAddress.isEmpty ? 'No Address Provided' : order.deliveryAddress,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),

                // Items list
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ITEMS ORDERED',
                        style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      ...order.items.map((item) {
                        final String itemName = item.name;
                        final int itemQty = item.quantity;
                        final double itemPrice = item.unitPrice;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$itemQty x $itemName',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                                ),
                              ),
                              Text(
                                '£${(itemPrice * itemQty).toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Order Value', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                Text('£${order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
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
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Customer Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                                Text(
                                  '£${order.paidAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: merchantGreen),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons based on Order Status Tree:
                // PENDING -> REJECTED or CONFIRMED -> PREPARING -> READY -> OUT_FOR_DELIVERY -> DELIVERED
                if (order.status == 'PENDING') ...[
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _rejectOrderDialog(state, order),
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: merchantGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: () => _confirmOrderDialog(state, order),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (order.status != 'DELIVERED' && order.status != 'REJECTED' && order.status != 'CANCELLED') ...[
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: merchantGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () => _updateStatusDialog(state, order),
                        child: Text(
                          _getActionButtonLabel(order.status),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'PENDING':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'REJECTED':
      case 'CANCELLED':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      case 'CONFIRMED':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF2563EB);
        break;
      case 'PREPARING':
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        break;
      case 'READY':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        break;
      case 'OUT_FOR_DELIVERY':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7C3AED);
        break;
      case 'DELIVERED':
        bg = const Color(0xFFDEF7EC);
        fg = const Color(0xFF03543F);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getActionButtonLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Confirm Order';
      case 'CONFIRMED':
        return 'Start Preparing';
      case 'PREPARING':
        return 'Mark as Ready';
      case 'READY':
        return 'Send out for Delivery';
      case 'OUT_FOR_DELIVERY':
        return 'Verify OTP & Mark Delivered';
      default:
        return 'Update Status';
    }
  }

  String _getNextStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'CONFIRMED';
      case 'CONFIRMED':
        return 'PREPARING';
      case 'PREPARING':
        return 'READY';
      case 'READY':
        return 'OUT_FOR_DELIVERY';
      case 'OUT_FOR_DELIVERY':
        return 'DELIVERED';
      default:
        return 'DELIVERED';
    }
  }

  void _confirmOrderDialog(RestaurantStateProvider state, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Are you sure you want to confirm Order #${order.orderNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A859),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await state.updateOrderStatus(order.id, 'CONFIRMED');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order Confirmed!'), backgroundColor: Color(0xFF00A859)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  void _rejectOrderDialog(RestaurantStateProvider state, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
        content: Text('Are you sure you want to REJECT Order #${order.orderNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await state.updateOrderStatus(order.id, 'REJECTED');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order Rejected'), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Reject Order'),
          ),
        ],
      ),
    );
  }

  void _updateStatusDialog(RestaurantStateProvider state, Order order) {
    final nextStatus = _getNextStatus(order.status);

    if (nextStatus == 'DELIVERED') {
      _showOtpVerificationDialog(state, order);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Order Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Change order #${order.orderNumber} status from "${order.status}" to "$nextStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A859),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await state.updateOrderStatus(order.id, nextStatus);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order status updated to $nextStatus!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Update Status'),
          ),
        ],
      ),
    );
  }

  void _showOtpVerificationDialog(RestaurantStateProvider state, Order order) {
    final otpController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: Color(0xFF00A859), size: 24),
                  SizedBox(width: 8),
                  Text('Verify Delivery OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the 4-digit Delivery OTP provided by customer for Order #${order.orderNumber}:',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Color(0xFF1F2937),
                    ),
                    decoration: InputDecoration(
                      hintText: '••••',
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      fillColor: const Color(0xFFF3F4F6),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00A859), width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A859),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final inputOtp = otpController.text.trim();
                          if (inputOtp.length != 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid 4-digit OTP.')),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          try {
                            await state.updateOrderStatus(order.id, 'DELIVERED', deliveryOtp: inputOtp);
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('OTP Verified! Order marked as Delivered & Completed!'),
                                  backgroundColor: Color(0xFF00A859),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('OTP Verification Failed: ${e.toString().replaceAll('Exception: ', '')}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify & Complete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
