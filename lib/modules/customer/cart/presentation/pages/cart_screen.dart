import 'package:flutter/material.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/app/constants/api_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _addressController = TextEditingController(
    text: '123 Main Street, Apt 4B',
  );
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleCheckout(TiffinStateProvider state) async {
    final addressText = _addressController.text.trim();
    if (addressText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid delivery address')),
      );
      return;
    }

    try {
      final selectedAddr = state.selectedAddress;
      final order = await state.placeOrder(
        addressText,
        addressId: selectedAddr?.id,
        deliveryNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        simulateWorldpay: true,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed Successfully!'),
          content: Text(
            'Order #${order.orderNumber} has been received by ${state.selectedRestaurant?.name ?? "the kitchen"}.\nPayment Status: PAID (Worldpay Simulated)\nTotal: £${order.total.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                final dashboardState = context.findAncestorStateOfType<DashboardScreenState>();
                dashboardState?.setTab(0); // Return to Home
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          'Your Cart',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (state.cartItems.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(Icons.delete_outline, color: Color(0xFF9CA3AF)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart?'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          state.clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: state.cartItems.isEmpty
          ? _buildEmptyCart(context)
          : Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // List of Cart Items matching Screen 5 in design image
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = state.cartItems[index];
                          final imageUrl = ApiConfig.getFormattedImageUrl(cartItem.item.imageUrl);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
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
                            child: Row(
                              children: [
                                // Thumbnail Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    color: const Color(0xFFF3F4F6),
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, color: brandOrange),
                                          )
                                        : const Icon(Icons.fastfood, color: brandOrange),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Title, Badge & Price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (state.hasActiveSubscription && cartItem.itemType != 'Add-on')
                                                  ? const Color(0xFFECFDF5)
                                                  : const Color(0xFFFFF7ED),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              (state.hasActiveSubscription && cartItem.itemType != 'Add-on')
                                                  ? 'Covered by Plan (£${cartItem.unitPrice.toStringAsFixed(2)})'
                                                  : (cartItem.itemType == 'Add-on' ? 'Add-on (Separate Payment)' : 'Veg'),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: (state.hasActiveSubscription && cartItem.itemType != 'Add-on')
                                                    ? const Color(0xFF00A859)
                                                    : brandOrange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (state.hasActiveSubscription && cartItem.itemType != 'Add-on')
                                            ? 'Included in Plan (Value: £${cartItem.unitPrice.toStringAsFixed(2)})'
                                            : '£${cartItem.unitPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          color: (state.hasActiveSubscription && cartItem.itemType != 'Add-on')
                                              ? const Color(0xFF00A859)
                                              : brandOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Qty Counter (- / qty / +)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.remove, size: 14, color: Color(0xFF374151)),
                                        onPressed: () {
                                          state.updateCartQuantity(cartItem.item.id, cartItem.itemType, cartItem.quantity - 1);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: Text(
                                          '${cartItem.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.add, size: 14, color: brandOrange),
                                        onPressed: () {
                                          state.updateCartQuantity(cartItem.item.id, cartItem.itemType, cartItem.quantity + 1);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Subscription Meal Allowance Info Card
                      if (state.hasActiveSubscription) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.card_membership, color: Color(0xFF00A859), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Active Plan: ${state.activeSubscription}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF166534)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subscription Meal Cost:', style: TextStyle(fontSize: 12, color: Color(0xFF166534))),
                                  const Text('FREE (£0.00 Already Paid)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00A859))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Meals in Cart: ${state.subscriptionMealsInCart}', style: const TextStyle(fontSize: 12, color: Color(0xFF166534))),
                                  Text(
                                    'Allowance: ${state.remainingSubscriptionMeals} ➔ ${(state.remainingSubscriptionMeals - state.subscriptionMealsInCart).clamp(0, 9999)} left',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Delivery Address & Notes Input Card
                      Container(
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
                                const Row(
                                  children: [
                                    Icon(Icons.location_on, color: brandOrange, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Delivery Address',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                                    ),
                                  ],
                                ),
                                if (state.addresses.isNotEmpty)
                                  DropdownButton<int>(
                                    value: state.selectedAddress?.id,
                                    hint: const Text('Saved Address', style: TextStyle(fontSize: 12)),
                                    underline: const SizedBox(),
                                    items: state.addresses.map((a) {
                                      return DropdownMenuItem<int>(
                                        value: a.id,
                                        child: Text(
                                          '${a.label} (${a.line1})',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (id) {
                                      if (id != null) {
                                        final selected = state.addresses.firstWhere((a) => a.id == id);
                                        state.selectedAddress = selected;
                                        _addressController.text = '${selected.line1}, ${selected.city}, ${selected.pincode}';
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your delivery address...',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bill Details Card
                      Container(
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
                              'Bill Details',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                            ),
                            const SizedBox(height: 12),
                            if (state.hasActiveSubscription) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subscription Meal(s)', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                                  Text('-£${state.subscriptionCoveredAmount.toStringAsFixed(2)} (Covered)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00A859))),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(state.hasActiveSubscription ? 'Add-on Items Subtotal' : 'Item Total', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                                Text('£${state.effectiveSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Delivery Fee', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                                Text(
                                  state.effectiveDeliveryFee > 0 ? '£${state.effectiveDeliveryFee.toStringAsFixed(2)}' : 'FREE',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: state.effectiveDeliveryFee > 0 ? const Color(0xFF374151) : const Color(0xFF00A859)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Taxes (${state.taxRatePercentage.toStringAsFixed(1)}%)', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                                Text('£${state.effectiveTaxAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Payable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937))),
                                Text(
                                  '£${state.customerPaidAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: state.customerPaidAmount == 0.0 ? const Color(0xFF00A859) : brandOrange),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Sticky Orange Checkout Button
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: state.isLoading ? null : () => _handleCheckout(state),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '£${state.effectiveTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              state.isLoading ? 'Processing...' : 'Proceed to Checkout',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    const Color brandOrange = Color(0xFFFF5E00);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 64, color: brandOrange),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse meals and add-ons to build your order.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandOrange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final dashboardState = context.findAncestorStateOfType<DashboardScreenState>();
                dashboardState?.setTab(0); // Home tab
              },
              icon: const Icon(Icons.restaurant_menu, color: Colors.white),
              label: const Text('Explore Meals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
