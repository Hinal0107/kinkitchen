import 'package:flutter/material.dart';
import '../../../../core/widgets/food_image.dart';
import '../bloc/tiffin_state_provider.dart';
import 'dashboard_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _addressController = TextEditingController(text: '123 Main Street, Apt 4B');

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color customerOrange = Color(0xFFFF5E00);
    const Color restaurantGreen = Color(0xFF00A859);
    final bool hasActiveSub = state.activeSubscription != 'None';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Your Cart',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (state.cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
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
                        child: const Text('Clear All', style: TextStyle(color: Color(0xFFEF4444))),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: state.cartItems.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // 1. Cart Items List
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = state.cartItems[index];
                      final item = cartItem.item;
                      final bool isAddon = state.isAddonItem(item);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAddon ? const Color(0xFFF59E0B) : const Color(0xFFF3F4F6),
                            width: isAddon ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            FoodImage(
                              title: item.name,
                              width: 60,
                              height: 60,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  
                                  // Addon vs Subscription Item Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isAddon
                                          ? const Color(0xFFFFFBEB)
                                          : (hasActiveSub ? restaurantGreen.withOpacity(0.1) : const Color(0xFFF3F4F6)),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isAddon
                                            ? const Color(0xFFFCD34D)
                                            : (hasActiveSub ? restaurantGreen.withOpacity(0.3) : const Color(0xFFE5E7EB)),
                                      ),
                                    ),
                                    child: Text(
                                      isAddon
                                          ? 'EXTRA ADD-ON • SEPARATE PAYMENT'
                                          : (hasActiveSub ? 'COVERED BY SUBSCRIPTION (₹0.00)' : 'REGULAR ITEM'),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isAddon
                                            ? const Color(0xFFB45309)
                                            : (hasActiveSub ? restaurantGreen : const Color(0xFF4B5563)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  Text(
                                    (!isAddon && hasActiveSub)
                                        ? '₹0.00 (Prepaid Plan)'
                                        : '₹${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: (!isAddon && hasActiveSub) ? restaurantGreen : customerOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Quantity selector
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => state.removeFromCart(item),
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                    color: customerOrange,
                                    size: 22,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    cartItem.quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => state.addToCart(item),
                                  child: const Icon(
                                    Icons.add_circle_outline,
                                    color: customerOrange,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Delivery Address input box
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Delivery Address',
                      hintText: 'Enter address...',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    ),
                  ),
                ),

                // 2. Bill Details Section with Separate Add-on Payment Breakdown
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Bill Details',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'Separate Payment Breakdown',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (hasActiveSub) ...[
                        _buildBillRow('Subscription Included Meals', '₹0.00 (Prepaid)'),
                        const SizedBox(height: 8),
                      ],

                      _buildBillRow(
                        hasActiveSub ? 'Extra Add-ons Subtotal' : 'Item Subtotal',
                        '₹${(hasActiveSub ? state.addonSubtotal : state.subtotal).toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildBillRow('Delivery Fee', '₹${state.deliveryFee.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildBillRow('Taxes & Packaging', '₹${state.tax.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),

                      // Final Total Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasActiveSub ? 'Add-on Separate Payment' : 'Total Amount',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                              ),
                              if (hasActiveSub)
                                const Text(
                                  'Add-ons are not included in subscription',
                                  style: TextStyle(fontSize: 10, color: Color(0xFFD97706), fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                          Text(
                            '₹${(hasActiveSub ? state.addonTotalPayable : state.total).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: customerOrange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Terms Link
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/terms-and-conditions');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.info_outline, size: 14, color: Color(0xFF6B7280)),
                            SizedBox(width: 4),
                            Text(
                              'By proceeding, you agree to Subscription & Add-on Terms',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Checkout Action block
                      GestureDetector(
                        onTap: () async {
                          final address = _addressController.text.trim();
                          if (address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please specify a delivery address.')),
                            );
                            return;
                          }

                          try {
                            final order = await state.placeOrder(address);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Order Placed Successfully!'),
                                content: Text('Order #${order.orderNumber} created.\n\nAdd-on separate payment total: ₹${(hasActiveSub ? state.addonTotalPayable : state.total).toStringAsFixed(2)}'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.findAncestorStateOfType<DashboardScreenState>()?.setTab(0);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Checkout failed: $e')),
                            );
                          }
                        },
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: customerOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.08),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    '₹${(hasActiveSub ? state.addonTotalPayable : state.total).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Proceed to Checkout',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    const Color customerOrange = Color(0xFFFF5E00);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: customerOrange.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: customerOrange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add delicious home-style meals or extra add-ons to your cart.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: customerOrange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                context.findAncestorStateOfType<DashboardScreenState>()?.setTab(1);
              },
              child: const Text('Browse Menu'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
        ),
      ],
    );
  }
}
