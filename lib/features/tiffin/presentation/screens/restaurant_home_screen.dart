import 'package:flutter/material.dart';
import '../../../../core/widgets/food_image.dart';
import '../bloc/restaurant_state_provider.dart';
import 'restaurant_dashboard_screen.dart';

class RestaurantHomeScreen extends StatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  State<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = RestaurantStateScope.of(context);
    // Auto-fetch merchant records on load
    if (state.menuItems.isEmpty && !state.isLoading && state.errorMessage == null) {
      Future.microtask(() {
        state.fetchProfile();
        state.fetchCategories();
        state.fetchMenuItems();
        state.fetchPlans();
        state.fetchOrders();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = RestaurantStateScope.of(context);
    const Color merchantGreen = Color(0xFF00A859);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'RESTAURANT PORTAL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.storefront, size: 14, color: merchantGreen),
                          const SizedBox(width: 4),
                          Text(
                            state.profile?.name ?? 'ABC Restaurant, Main Branch',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Toggle demo switch
                      TextButton.icon(
                        onPressed: () => state.toggleKitchenState(),
                        icon: const Icon(Icons.swap_horiz, size: 14, color: merchantGreen),
                        label: Text(
                          state.isKitchenEmpty ? 'Empty State' : 'Filled State',
                          style: const TextStyle(fontSize: 11, color: merchantGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE5E7EB),
                        child: Icon(Icons.person, color: Color(0xFF4B5563), size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, RestaurantStateProvider state) {
    const Color merchantGreen = Color(0xFF00A859);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: merchantGreen));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 52, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: merchantGreen),
                onPressed: () {
                  state.fetchProfile();
                  state.fetchMenuItems();
                  state.fetchPlans();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Determine Empty State dynamically based on database items AND demo toggle
    final isDatabaseEmpty = state.menuItems.isEmpty && state.plans.isEmpty;
    if (state.isKitchenEmpty || isDatabaseEmpty) {
      return _buildEmptyKitchenState(context, state);
    }

    return _buildFilledDashboardState(context, state);
  }

  Widget _buildEmptyKitchenState(BuildContext context, RestaurantStateProvider state) {
    const Color merchantGreen = Color(0xFF00A859);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monday, August 24, 2026',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Good Morning, ${state.profile?.name ?? 'ABC Restaurant'}',
                  style: const TextStyle(color: Color(0xFF1F2937), fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
            ),
            child: Column(
              children: const [
                Icon(Icons.inventory_2_outlined, size: 56, color: Color(0xFF9CA3AF)),
                SizedBox(height: 16),
                Text(
                  'Your Kitchen is Empty!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                SizedBox(height: 8),
                Text(
                  'No meals or menus added yet. Start by creating today\'s meal, tomorrow\'s meal, your menu, or a subscription plan to get your restaurant online.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              _buildSetupCard(
                icon: Icons.today_outlined,
                title: 'Create Today\'s Meal',
                subtitle: 'Set up what you\'re serving right now.',
                btnText: 'Add Now',
                btnColor: merchantGreen,
                onTap: () {
                  // Trigger direct categories and menu views
                  context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(1);
                },
              ),
              _buildSetupCard(
                icon: Icons.next_plan_outlined,
                title: 'Create Tomorrow\'s Meal',
                subtitle: 'Plan ahead for the next day\'s specials.',
                btnText: 'Plan Ahead',
                btnColor: const Color(0xFF1F2937),
                onTap: () {
                  context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(3);
                },
              ),
              _buildSetupCard(
                icon: Icons.list_alt_outlined,
                title: 'Create Menu',
                subtitle: 'Build your full list of offerings.',
                btnText: 'Create Menu',
                btnColor: merchantGreen,
                onTap: () {
                  context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(1);
                },
              ),
              _buildSetupCard(
                icon: Icons.card_membership_outlined,
                title: 'Create Subscription',
                subtitle: 'Offer recurring meal packages.',
                btnText: 'Add Plan',
                btnColor: merchantGreen,
                onTap: () {
                  context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(2);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilledDashboardState(BuildContext context, RestaurantStateProvider state) {
    const Color merchantGreen = Color(0xFF00A859);

    // Fetch primary items dynamically from menu list
    final todayMeal = state.todayMeals.isNotEmpty ? state.todayMeals.first : null;
    final tomorrowMeal = state.tomorrowMeals.isNotEmpty ? state.tomorrowMeals.first : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: merchantGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: merchantGreen.withOpacity(0.12), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.room_service_outlined, size: 28, color: merchantGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome back, Chef!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Here\'s your kitchen overview for today.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 1. TODAY'S MEAL CARD
          if (todayMeal != null) ...[
            _buildDashboardSectionHeader(
              "Today's Meal: ${todayMeal['title']}",
              '₹${todayMeal['price'].toStringAsFixed(0)}',
              isVeg: todayMeal['isVeg'],
              status: todayMeal['isActive'] ? 'Available' : 'Inactive',
              statusColor: todayMeal['isActive'] ? merchantGreen : Colors.red,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FoodImage(title: todayMeal['title'], height: 140),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: merchantGreen),
                                    foregroundColor: merchantGreen,
                                  ),
                                  onPressed: () {
                                    context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(3);
                                  },
                                  child: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: merchantGreen,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {},
                                  child: const Text('View'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 2. TOMORROW'S MEAL CARD
          if (tomorrowMeal != null) ...[
            _buildDashboardSectionHeader(
              "Tomorrow's Meal: ${tomorrowMeal['title']}",
              '₹${tomorrowMeal['price'].toStringAsFixed(0)}',
              isVeg: tomorrowMeal['isVeg'],
              status: tomorrowMeal['isActive'] ? 'Scheduled' : 'Unavailable',
              statusColor: tomorrowMeal['isActive'] ? const Color(0xFF3B82F6) : Colors.red,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FoodImage(title: tomorrowMeal['title'], height: 140),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: merchantGreen),
                                    foregroundColor: merchantGreen,
                                  ),
                                  onPressed: () {
                                    context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(3);
                                  },
                                  child: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: merchantGreen,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {},
                                  child: const Text('View'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 3. MENU SUMMARY
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 28, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menu Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                GestureDetector(
                  onTap: () {
                    context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(1);
                  },
                  child: const Text(
                    'Manage Menu',
                    style: TextStyle(color: merchantGreen, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${state.totalItemsCount}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'TOTAL ITEMS',
                          style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Active items:\n${state.activeItemsCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.4, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. ACTIVE PLANS LIST
          if (state.plans.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 28, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Plans',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(2);
                    },
                    child: const Text(
                      'Manage Plans',
                      style: TextStyle(color: merchantGreen, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                ),
                child: Column(
                  children: state.plans.map((p) {
                    return Column(
                      children: [
                        _buildDashboardPlanRow(p['title'], '₹${p['price'].toStringAsFixed(0)}'),
                        if (state.plans.last != p) const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSetupCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String btnText,
    required Color btnColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28, color: btnColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), height: 1.3),
              ),
            ],
          ),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: onTap,
              child: Text(btnText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSectionHeader(
    String title,
    String price, {
    required bool isVeg,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildVegDot(isVeg),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                price,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVegDot(bool isVeg) {
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

  Widget _buildDashboardPlanRow(String planName, String price) {
    const Color merchantGreen = Color(0xFF00A859);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            planName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
          ),
          Text(
            price,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: merchantGreen),
          ),
        ],
      ),
    );
  }
}
