import 'package:flutter/material.dart';
import '../bloc/restaurant_state_provider.dart';
import 'restaurant_dashboard_screen.dart';
import '../../../../models/order.dart';

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
      return orders.where((o) => o.status == 'DELIVERED').toList();
    } else if (type == 'active') {
      return orders.where((o) => o.status != 'DELIVERED').toList();
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
                            order.customerName ?? 'Guest Customer',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151)),
                          ),
                        ],
                      ),
                      if (order.customerPhone != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 8),
                            Text(
                              order.customerPhone!,
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
                        final String itemName = item['menu_item']?['name'] ?? item['name'] ?? 'Item';
                        final int itemQty = item['quantity'] ?? 1;
                        final double itemPrice = (item['price'] as num? ?? 0.0).toDouble();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$itemQty x $itemName',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                              ),
                              Text(
                                '₹${(itemPrice * itemQty).toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL AMOUNT',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                          ),
                          Text(
                            '₹${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: merchantGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Button based on status
                if (order.status != 'DELIVERED') ...[
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
    switch (status) {
      case 'PENDING':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
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
        status,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getActionButtonLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Confirm Order';
      case 'CONFIRMED':
        return 'Start Preparing';
      case 'PREPARING':
        return 'Mark as Ready';
      case 'READY':
        return 'Send out for Delivery';
      case 'OUT_FOR_DELIVERY':
        return 'Mark as Delivered';
      default:
        return 'Update Status';
    }
  }

  String _getNextStatus(String status) {
    switch (status) {
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

  void _updateStatusDialog(RestaurantStateProvider state, Order order) {
    final nextStatus = _getNextStatus(order.status);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text('Do you want to change order #${order.orderNumber} status from "${order.status}" to "$nextStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A859), foregroundColor: Colors.white),
            onPressed: () {
              state.updateOrderStatus(order.id, nextStatus);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order status updated to $nextStatus')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
