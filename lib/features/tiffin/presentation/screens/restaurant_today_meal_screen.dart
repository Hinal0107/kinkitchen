import 'package:flutter/material.dart';
import '../../../../core/widgets/food_image.dart';
import '../bloc/restaurant_state_provider.dart';
import 'restaurant_dashboard_screen.dart';

class RestaurantTodayMealScreen extends StatefulWidget {
  const RestaurantTodayMealScreen({super.key});

  @override
  State<RestaurantTodayMealScreen> createState() => _RestaurantTodayMealScreenState();
}

class _RestaurantTodayMealScreenState extends State<RestaurantTodayMealScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dialog Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  bool _dialogIsVeg = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _showAddTodayMealDialog(RestaurantStateProvider state) {
    _titleController.clear();
    _priceController.clear();
    _qtyController.clear();
    _dialogIsVeg = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          const Color merchantGreen = Color(0xFF00A859);

          return AlertDialog(
            title: const Text('Add Today\'s Meal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Meal Name', hintText: 'e.g. Gujarati Thali Special'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (₹)', hintText: 'e.g. 120'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Quantity', hintText: 'e.g. 50'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Is Vegetarian?', style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        activeColor: merchantGreen,
                        value: _dialogIsVeg,
                        onChanged: (val) {
                          setDialogState(() {
                            _dialogIsVeg = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: merchantGreen, foregroundColor: Colors.white),
                onPressed: () {
                  final String title = _titleController.text.trim();
                  final double price = double.tryParse(_priceController.text) ?? 0.0;
                  final int qty = int.tryParse(_qtyController.text) ?? 0;

                  if (title.isNotEmpty && price > 0 && qty > 0) {
                    state.addTodayMeal(title, price, qty, _dialogIsVeg);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"$title" added to Today\'s menu!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields correctly.')),
                    );
                  }
                },
                child: const Text('Add Meal'),
              ),
            ],
          );
        },
      ),
    );
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
          'TiffinPro - Downtown',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: merchantGreen,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: merchantGreen,
          tabs: const [
            Tab(text: 'Today\'s Meal'),
            Tab(text: 'Tomorrow\'s Meal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sub-tab A: Today's Meals
          _buildTodayTab(state, merchantGreen),
          
          // Sub-tab B: Tomorrow's Meals
          _buildTomorrowTab(state, merchantGreen),
        ],
      ),
    );
  }

  // TODAY'S MEAL TAB PANEL
  Widget _buildTodayTab(RestaurantStateProvider state, Color merchantGreen) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: merchantGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTodayMealDialog(state),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subtitle Banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Text(
              'Manage Today\'s Meal\nUpdate availability, quantities, and pricing for today\'s menu offerings.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.4),
            ),
          ),
          
          // Meals List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.todayMeals.length,
              itemBuilder: (context, index) {
                final meal = state.todayMeals[index];
                final String title = meal['title'];
                final double price = meal['price'];
                final String gst = meal['gst'];
                final int availableQty = meal['availableQty'];
                final int totalQty = meal['totalQty'];
                final bool isActive = meal['isActive'];
                final String createdAt = meal['createdAt'];
                final bool isVeg = meal['isVeg'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FoodImage(title: title, width: 72, height: 72, borderRadius: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildVegIndicator(isVeg),
                                    const SizedBox(width: 8),
                                    Text(
                                      title,
                                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Price Breakdown: ₹${price.toStringAsFixed(0)} + $gst GST',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Available: $availableQty/$totalQty',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: availableQty > 0 ? merchantGreen : const Color(0xFFEF4444),
                                      ),
                                    ),
                                    Text(
                                      'Created $createdAt',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      const SizedBox(height: 8),
                      
                      // Action controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), foregroundColor: const Color(0xFF4B5563)),
                                onPressed: () {},
                                child: const Text('View'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), foregroundColor: const Color(0xFF4B5563)),
                                onPressed: () {},
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Switch(
                                activeColor: merchantGreen,
                                value: isActive,
                                onChanged: (val) {
                                  state.toggleTodayMealActive(title);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove Meal'),
                                      content: Text('Are you sure you want to remove "$title" from today\'s menu?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () {
                                            state.deleteTodayMeal(title);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('"$title" removed!')),
                                            );
                                          },
                                          child: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444))),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // TOMORROW'S MEAL TAB PANEL
  Widget _buildTomorrowTab(RestaurantStateProvider state, Color merchantGreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Subtitle Banner
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Text(
            'Manage Tomorrow\'s Meal\nUpdate menu availability and quantities for the upcoming day.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.4),
          ),
        ),
        
        // Meals List
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: state.tomorrowMeals.length,
            itemBuilder: (context, index) {
              final meal = state.tomorrowMeals[index];
              final String title = meal['title'];
              final double price = meal['price'];
              final double gstVal = price * 0.05;
              final double finalPrice = price + gstVal;
              final int availableQty = meal['availableQty'];
              final int totalQty = meal['totalQty'];
              final bool isActive = meal['isActive'];
              final bool isVeg = meal['isVeg'];

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? merchantGreen : const Color(0xFFE5E7EB),
                    width: isActive ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header title info
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildVegIndicator(isVeg),
                              const SizedBox(width: 8),
                              Text(
                                title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive ? merchantGreen.withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Available' : 'Unavailable',
                              style: TextStyle(
                                color: isActive ? merchantGreen : const Color(0xFFEF4444),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    
                    // Table Details Info
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildMealDetailRow('DURATION', '1 Day'),
                          const SizedBox(height: 6),
                          _buildMealDetailRow('MEAL TYPE', '1 Meal'),
                          const SizedBox(height: 6),
                          _buildMealDetailRow('BASE PRICE', '₹${price.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          _buildMealDetailRow('GST (5%)', '₹${gstVal.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          _buildMealDetailRow('FINAL PRICE', '₹${finalPrice.toStringAsFixed(2)}', valueColor: merchantGreen),
                          const SizedBox(height: 6),
                          _buildMealDetailRow('QTY AVAILABLE', '$availableQty / $totalQty'),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),

                    // Bottom Action button
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: isActive
                          ? Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), foregroundColor: const Color(0xFF4B5563)),
                                    onPressed: () {},
                                    child: const Text('View'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), foregroundColor: const Color(0xFF4B5563)),
                                    onPressed: () {},
                                    child: const Text('Edit'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                                  onPressed: () {
                                    state.deleteTomorrowMeal(title);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('"$title" set as Unavailable for Tomorrow')),
                                    );
                                  },
                                ),
                              ],
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: merchantGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  state.addTomorrowMeal(title);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('"$title" is Scheduled for Tomorrow!')),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Tomorrow\'s Meal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMealDetailRow(String label, String val, {Color valueColor = const Color(0xFF374151)}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        Text(val, style: TextStyle(fontSize: 13, color: valueColor, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildVegIndicator(bool isVeg) {
    final Color color = isVeg ? const Color(0xFF00A859) : const Color(0xFF8B0000);
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
