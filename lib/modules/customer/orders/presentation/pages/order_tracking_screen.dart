import 'package:flutter/material.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/modules/customer/orders/presentation/widgets/live_order_stepper.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/shared/models/order.dart';
import 'package:kinkitchen/shared/repositories/order_repository.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  bool _isLoading = true;
  String? _errorMessage;
  OrderTrackingData? _trackingData;
  Order? _orderDetail;

  @override
  void initState() {
    super.initState();
    _loadTrackingInfo();
  }

  Future<void> _loadTrackingInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tracking = await _orderRepository.getOrderTracking(widget.orderId);
      Order? detail;
      try {
        detail = await _orderRepository.getOrderDetails(widget.orderId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _trackingData = tracking;
          _orderDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmReceipt(String otpInput) async {
    try {
      final state = TiffinStateScope.of(context);
      await state.confirmOrderReceipt(widget.orderId);
      await _loadTrackingInfo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order receipt confirmed! Delivery completed.'),
            backgroundColor: Color(0xFF00A859),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFF5E00);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _trackingData != null ? 'Track Order #${_trackingData!.orderNumber}' : 'Order Tracking',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4B5563)),
            onPressed: _loadTrackingInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brandOrange))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 56, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load order tracking',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _loadTrackingInfo,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _trackingData == null
                  ? const SizedBox()
                  : RefreshIndicator(
                      onRefresh: _loadTrackingInfo,
                      color: brandOrange,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Restaurant & Order Info Card
                            _buildInfoCard(_trackingData!),
                            const SizedBox(height: 16),

                            // PROMINENT HIGH-CONTRAST OTP BANNER (When OUT_FOR_DELIVERY)
                            if (_trackingData!.deliveryStatus.toUpperCase() == 'OUT_FOR_DELIVERY' ||
                                _trackingData!.orderStatus.toUpperCase() == 'OUT_FOR_DELIVERY') ...[
                              _buildOtpBanner(_trackingData!),
                              const SizedBox(height: 16),
                            ],

                            // Live Order Stepper
                            LiveOrderStepper(
                              orderStatus: _trackingData!.orderStatus,
                              deliveryStatus: _trackingData!.deliveryStatus,
                              timeline: _trackingData!.timeline,
                            ),
                            const SizedBox(height: 16),

                            // Order Details / Items Summary
                            if (_orderDetail != null) _buildOrderSummary(_orderDetail!),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildInfoCard(OrderTrackingData data) {
    const Color brandOrange = Color(0xFFFF5E00);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: brandOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront, color: brandOrange, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.restaurantName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
                      ),
                      if (data.scheduledDate.isNotEmpty)
                        Text(
                          'Scheduled for ${data.scheduledDate}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: brandOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.orderStatus.replaceAll('_', ' '),
                  style: const TextStyle(color: brandOrange, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBanner(OrderTrackingData data) {
    const Color brandOrange = Color(0xFFFF5E00);
    final String? otp = data.deliveryOtp;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5E00), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF5E00),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.two_wheeler, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'OUT FOR DELIVERY!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Share this Handover OTP with your delivery driver upon arrival:',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),

          // OTP Display Box
          if (otp != null && otp.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, color: brandOrange, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'OTP: $otp',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: brandOrange,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: brandOrange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _confirmReceipt(''),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text(
                'Confirm Receipt & Reveal OTP',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER SUMMARY',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),

          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.quantity}x ${item.title}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1F2937)),
                  ),
                  Text(
                    '£${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937))),
              Text(
                '£${order.paidAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF5E00)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
