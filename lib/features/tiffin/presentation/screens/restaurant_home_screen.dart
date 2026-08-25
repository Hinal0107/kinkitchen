import 'package:flutter/material.dart';
import '../../../../core/widgets/food_image.dart';
import '../bloc/restaurant_state_provider.dart';
import 'restaurant_dashboard_screen.dart';
import 'restaurant_add_menu_item_screen.dart';

class RestaurantHomeScreen extends StatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  State<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasFetchedInitialData = false;

  // Dialog Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  bool _dialogIsVeg = true;

  // Add-on Dialog Controllers
  final _addonTitleController = TextEditingController();
  final _addonPriceController = TextEditingController();
  final _addonQtyController = TextEditingController();
  bool _addonIsVeg = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = RestaurantStateScope.of(context);
    // Auto-fetch merchant records on load once
    if (!_hasFetchedInitialData && !state.isLoading && state.errorMessage == null) {
      _hasFetchedInitialData = true;
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
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _addonTitleController.dispose();
    _addonPriceController.dispose();
    _addonQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = RestaurantStateScope.of(context);
    const Color merchantGreen = Color(0xFF00A859);

    final isDatabaseEmpty = state.menuItems.isEmpty && state.plans.isEmpty;
    final bool showTabs = !isDatabaseEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront, size: 14, color: merchantGreen),
                const SizedBox(width: 4),
                Text(
                  state.profile?.name ?? 'ABC Restaurant, Downtown',
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
        bottom: showTabs
            ? TabBar(
                controller: _tabController,
                labelColor: merchantGreen,
                unselectedLabelColor: const Color(0xFF6B7280),
                indicatorColor: merchantGreen,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.today, size: 18),
                    text: "Today's Meal",
                  ),
                  Tab(
                    icon: Icon(Icons.next_plan, size: 18),
                    text: "Tomorrow's Meal",
                  ),
                ],
              )
            : null,
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

    // Determine Empty State dynamically based on database items
    final isDatabaseEmpty = state.menuItems.isEmpty && state.plans.isEmpty;
    if (isDatabaseEmpty) {
      return _buildEmptyKitchenState(context, state);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTodayTab(state, merchantGreen),
        _buildTomorrowTab(state, merchantGreen),
      ],
    );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantAddMenuItemScreen(stateProvider: state),
                    ),
                  );
                },
              ),
              _buildSetupCard(
                icon: Icons.next_plan_outlined,
                title: 'Create Tomorrow\'s Meal',
                subtitle: 'Plan ahead for the next day\'s specials.',
                btnText: 'Plan Ahead',
                btnColor: const Color(0xFF1F2937),
                onTap: () {
                  _tabController.animateTo(1);
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

  // TODAY'S MEAL TAB PANEL
  Widget _buildTodayTab(RestaurantStateProvider state, Color merchantGreen) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: merchantGreen,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantAddMenuItemScreen(stateProvider: state),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
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
            
            // Meals Header
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                'TODAY\'S MEALS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
              ),
            ),

            // Meals List Cards
            if (state.todayMeals.isEmpty)
              _buildEmptyCard('No meals added for today.')
            else
              ...state.todayMeals.map((meal) => _buildTodayMealCard(state, meal, merchantGreen)),

            // Add-on Items Header
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ADD-ON ITEMS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: merchantGreen, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: () => _showAddAddonDialog(state),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Add Add-on', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Add-ons List Cards
            if (state.todayAddons.isEmpty)
              _buildEmptyCard('No add-on items added yet.')
            else
              ...state.todayAddons.map((addon) => _buildAddonCard(state, addon, true, merchantGreen)),
          ],
        ),
      ),
    );
  }

  // TOMORROW'S MEAL TAB PANEL
  Widget _buildTomorrowTab(RestaurantStateProvider state, Color merchantGreen) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
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
            
            // Meals Header
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                'TOMORROW\'S MEALS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
              ),
            ),

            // Tomorrow's Meals Cards
            if (state.tomorrowMeals.isEmpty)
              _buildEmptyCard('No meals scheduled for tomorrow.')
            else
              ...state.tomorrowMeals.map((meal) => _buildTomorrowMealCard(state, meal, merchantGreen)),

            // Add-on Items Header
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ADD-ON ITEMS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: merchantGreen, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: () => _showAddAddonDialog(state),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Add Add-on', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Tomorrow's Add-ons list
            if (state.tomorrowAddons.isEmpty)
              _buildEmptyCard('No add-on items added yet.')
            else
              ...state.tomorrowAddons.map((addon) => _buildAddonCard(state, addon, false, merchantGreen)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildTodayMealCard(RestaurantStateProvider state, Map<String, dynamic> meal, Color merchantGreen) {
    final String title = meal['title'];
    final double price = meal['price'];
    final String gst = meal['gst'];
    final int availableQty = meal['availableQty'];
    final int totalQty = meal['totalQty'];
    final bool isActive = meal['isActive'];
    final String createdAt = meal['createdAt'];
    final bool isVeg = meal['isVeg'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
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
                    onChanged: (val) async {
                      await state.toggleTodayMealActive(title);
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
                               onPressed: () async {
                                 await state.deleteTodayMeal(title);
                                 if (context.mounted) {
                                   Navigator.pop(context);
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('"$title" removed!')),
                                   );
                                 }
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
  }

  Widget _buildTomorrowMealCard(RestaurantStateProvider state, Map<String, dynamic> meal, Color merchantGreen) {
    final String title = meal['title'];
    final double price = meal['price'];
    final double gstVal = price * 0.05;
    final double finalPrice = price + gstVal;
    final int availableQty = meal['availableQty'];
    final int totalQty = meal['totalQty'];
    final bool isActive = meal['isActive'];
    final bool isVeg = meal['isVeg'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        onPressed: () async {
                          await state.deleteTomorrowMeal(title);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('"$title" set as Unavailable for Tomorrow')),
                            );
                          }
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
                      onPressed: () async {
                        await state.addTomorrowMeal(title);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"$title" is Scheduled for Tomorrow!')),
                          );
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Tomorrow\'s Meal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonCard(RestaurantStateProvider state, Map<String, dynamic> addon, bool isToday, Color merchantGreen) {
    final String title = addon['title'];
    final double price = addon['price'];
    final bool isVeg = addon['isVeg'];
    final bool isActive = isToday ? (addon['isActiveToday'] ?? true) : (addon['isActiveTomorrow'] ?? true);
    final int availableQty = addon['availableQty'] ?? 50;
    final int totalQty = addon['totalQty'] ?? 50;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildVegIndicator(isVeg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price: ₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      'Qty: $availableQty/$totalQty',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: availableQty > 0 ? merchantGreen : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            activeColor: merchantGreen,
            value: isActive,
            onChanged: (val) {
              if (isToday) {
                state.toggleAddonActiveToday(title);
              } else {
                state.toggleAddonActiveTomorrow(title);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Add-on'),
                  content: Text('Are you sure you want to remove "$title" from the add-ons list?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        await state.deleteAddon(title);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Add-on "$title" removed!')),
                          );
                        }
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

  void _showAddAddonDialog(RestaurantStateProvider state) {
    _addonTitleController.clear();
    _addonPriceController.clear();
    _addonQtyController.clear();
    _addonIsVeg = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          const Color merchantGreen = Color(0xFF00A859);

          return AlertDialog(
            title: const Text('Add Add-on Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _addonTitleController,
                    decoration: const InputDecoration(labelText: 'Add-on Name', hintText: 'e.g. Masala Chaas'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addonPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (₹)', hintText: 'e.g. 20'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addonQtyController,
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
                        value: _addonIsVeg,
                        onChanged: (val) {
                          setDialogState(() {
                            _addonIsVeg = val;
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
                onPressed: () async {
                  final String title = _addonTitleController.text.trim();
                  final double price = double.tryParse(_addonPriceController.text) ?? 0.0;
                  final int qty = int.tryParse(_addonQtyController.text) ?? 0;

                  if (title.isNotEmpty && price > 0 && qty > 0) {
                    await state.addAddon(title, price, qty, _addonIsVeg);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Add-on "$title" added!')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields correctly.')),
                    );
                  }
                },
                child: const Text('Add Add-on'),
              ),
            ],
          );
        },
      ),
    );
  }
}
