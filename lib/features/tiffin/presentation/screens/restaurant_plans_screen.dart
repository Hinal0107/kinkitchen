import 'package:flutter/material.dart';
import '../bloc/restaurant_state_provider.dart';
import 'restaurant_dashboard_screen.dart';
import 'restaurant_add_plan_screen.dart';

class RestaurantPlansScreen extends StatefulWidget {
  const RestaurantPlansScreen({super.key});

  @override
  State<RestaurantPlansScreen> createState() => _RestaurantPlansScreenState();
}

class _RestaurantPlansScreenState extends State<RestaurantPlansScreen> {
  String _selectedTab = 'All Plans';

  void _openAddPlanScreen(
    RestaurantStateProvider state, {
    Map<String, dynamic>? existingPlan,
    bool isEdit = false,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddPlanScreen(
          stateProvider: state,
          existingPlan: existingPlan,
          isEdit: isEdit,
        ),
      ),
    );
    await state.fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    final state = RestaurantStateScope.of(context);
    const Color merchantGreen = Color(0xFF00A859);

    final List<String> tabs = ['All Plans', 'Active', 'Drafts'];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Subscription Plans',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4B5563)),
            onPressed: () => _openAddPlanScreen(state),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tabs.map((tabName) {
                final isSelected = _selectedTab == tabName;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = tabName;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? merchantGreen : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Text(
                        tabName,
                        style: TextStyle(
                          color: isSelected ? merchantGreen : const Color(0xFF6B7280),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Plans List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              // We add 1 for the "+ Add New Plan" dotted card at the end
              itemCount: state.plans.length + 1,
              itemBuilder: (context, index) {
                if (index == state.plans.length) {
                  return _buildDottedAddCard(state);
                }

                final plan = state.plans[index];
                final String title = plan['title'];
                final double price = plan['price'];
                final String period = plan['period'];
                final String duration = plan['duration'];
                final String meals = plan['meals'];
                final String mealType = plan['mealType'];
                final String taxes = plan['taxesAndDisc'];
                final bool isPopular = plan['isPopular'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Title + Price
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isPopular)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: merchantGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                        child: const Text('Popular', style: TextStyle(color: merchantGreen, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(8)),
                                      child: const Text('Active', style: TextStyle(color: Color(0xFF4B5563), fontSize: 8, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  meals,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                            Text(
                              '£${price.toStringAsFixed(2)}$period',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: merchantGreen),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      
                      // Details Block
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildPlanDetailRow('DURATION', duration),
                            const SizedBox(height: 8),
                            _buildPlanDetailRow('MEALS COUNT', meals),
                            const SizedBox(height: 8),
                            _buildPlanDetailRow('MEAL TYPE', mealType),
                            const SizedBox(height: 8),
                            _buildPlanDetailRow('TAXES & DISCOUNT', taxes),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), foregroundColor: const Color(0xFF4B5563)),
                                onPressed: () => _openAddPlanScreen(state, existingPlan: plan, isEdit: true),
                                child: const Text('View'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), foregroundColor: const Color(0xFF4B5563)),
                                onPressed: () => _openAddPlanScreen(state, existingPlan: plan, isEdit: true),
                                child: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Plan'),
                                    content: Text('Are you sure you want to delete the plan "$title"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () {
                                          state.deleteSubscriptionPlan(title);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Plan "$title" deleted!')),
                                          );
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                                      ),
                                    ],
                                  ),
                                );
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
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        Text(val, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDottedAddCard(RestaurantStateProvider state) {
    const Color merchantGreen = Color(0xFF00A859);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 120,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: merchantGreen.withOpacity(0.4), width: 1.5, style: BorderStyle.values[1]),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
        ),
        onPressed: () => _openAddPlanScreen(state),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: merchantGreen, size: 28),
            SizedBox(height: 8),
            Text(
              'Add New Plan',
              style: TextStyle(color: merchantGreen, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Create custom subscription plans for your customers.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
