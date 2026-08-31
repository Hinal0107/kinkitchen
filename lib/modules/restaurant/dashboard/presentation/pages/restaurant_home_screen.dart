import 'package:flutter/material.dart';
import 'package:kinkitchen/core/widgets/food_image.dart';
import 'package:kinkitchen/core/widgets/meal_card_widget.dart';
import 'package:kinkitchen/modules/customer/profile/presentation/pages/notifications_screen.dart';
import 'package:kinkitchen/modules/restaurant/addons/presentation/pages/restaurant_add_addon_screen.dart';
import 'package:kinkitchen/modules/restaurant/menu/presentation/pages/restaurant_add_menu_item_screen.dart';
import 'package:kinkitchen/modules/restaurant/restaurant_state_provider.dart';
import 'package:kinkitchen/modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';

class RestaurantHomeScreen extends StatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  State<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasFetchedInitialData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = RestaurantStateScope.of(context);
    if (!_hasFetchedInitialData &&
        !state.isLoading &&
        state.errorMessage == null) {
      _hasFetchedInitialData = true;
      Future.microtask(() {
        state.fetchProfile();
        state.fetchCategories();
        state.fetchMenuItems();
        state.fetchDailyMeals();
        state.fetchPlans();
        state.fetchOrders();
        state.fetchNotifications();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Formatted date for display ---
  String get _formattedDate {
    final now = DateTime.now();
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month]} ${now.day}, ${now.year}';
  }

  String get _tomorrowFormatted {
    final tom = DateTime.now().add(const Duration(days: 1));
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[tom.month]} ${tom.day}, ${tom.year}';
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
                  state.profile?.name ?? 'My Restaurant',
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
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1F2937)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantStateScope(
                        notifier: state,
                        child: const NotificationsScreen(isRestaurant: true),
                      ),
                    ),
                  );
                },
              ),
              if (state.unreadNotificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: merchantGreen,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${state.unreadNotificationCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: merchantGreen,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: merchantGreen,
          tabs: const [
            Tab(icon: Icon(Icons.today, size: 18), text: "Today's Meal"),
            Tab(icon: Icon(Icons.next_plan, size: 18), text: "Tomorrow's Meal"),
          ],
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, RestaurantStateProvider state) {
    const Color merchantGreen = Color(0xFF00A859);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: merchantGreen),
      );
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

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTodayTab(state, merchantGreen),
        _buildTomorrowTab(state, merchantGreen),
      ],
    );
  }

  // ─── TODAY'S MEAL TAB ───────────────────────────────────────────────────────
  Widget _buildTodayTab(RestaurantStateProvider state, Color merchantGreen) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: merchantGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTodayMealDialog(state),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date banner
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: merchantGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.today,
                      color: Color(0xFF00A859),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "Manage Today's Meals",
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TODAY'S MEALS section
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                "TODAY'S MEALS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
            ),

            if (state.todayMeals.isEmpty)
              _buildEmptyState(
                icon: Icons.rice_bowl_outlined,
                title: "No meals added for today",
                subtitle:
                    "Tap the + button below to add today's meal plan for your customers.",
              )
            else
              ...state.todayMeals.map(
                (meal) => _buildTodayMealCard(state, meal, merchantGreen),
              ),

            // ADD-ONS section
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ADD-ON ITEMS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: merchantGreen,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showAddAddonDialog(state),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      'Add Add-on',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (state.todayAddons.isEmpty)
              _buildEmptyState(
                icon: Icons.add_shopping_cart_outlined,
                title: "No add-on items yet",
                subtitle:
                    "Add side dishes or beverages as add-ons for your customers.",
              )
            else
              SizedBox(
                height: 225,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.todayAddons.length,
                  itemBuilder: (context, index) {
                    return _buildAddonCard(
                      state,
                      state.todayAddons[index],
                      merchantGreen,
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── TOMORROW'S MEAL TAB ────────────────────────────────────────────────────
  Widget _buildTomorrowTab(RestaurantStateProvider state, Color merchantGreen) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: merchantGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTomorrowMealDialog(state),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date banner
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.next_plan,
                      color: Color(0xFF1F2937),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tomorrowFormatted,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "Plan Tomorrow's Meals",
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TOMORROW'S MEALS section
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                "TOMORROW'S MEALS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
            ),

            if (state.tomorrowMeals.isEmpty)
              _buildEmptyState(
                icon: Icons.next_plan_outlined,
                title: "No meals planned for tomorrow",
                subtitle:
                    "Tap the + button below to plan tomorrow's meal offerings.",
              )
            else
              ...state.tomorrowMeals.map(
                (meal) => _buildTomorrowMealCard(state, meal, merchantGreen),
              ),

            // ADD-ONS section
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ADD-ON ITEMS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: merchantGreen,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showAddAddonDialog(state),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      'Add Add-on',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (state.tomorrowAddons.isEmpty)
              _buildEmptyState(
                icon: Icons.add_shopping_cart_outlined,
                title: "No add-on items yet",
                subtitle:
                    "Add side dishes or beverages as add-ons for your customers.",
              )
            else
              SizedBox(
                height: 225,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.tomorrowAddons.length,
                  itemBuilder: (context, index) {
                    return _buildAddonCard(
                      state,
                      state.tomorrowAddons[index],
                      merchantGreen,
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── EMPTY STATE ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── TODAY MEAL CARD ──────────────────────────────────────────────────────────
  Widget _buildTodayMealCard(
    RestaurantStateProvider state,
    Map<String, dynamic> meal,
    Color merchantGreen,
  ) {
    final String title = meal['title'] ?? meal['name'] ?? 'Special Dish';
    final double price = (meal['price'] is num)
        ? (meal['price'] as num).toDouble()
        : (double.tryParse(meal['price']?.toString() ?? '') ?? 0.0);

    final double? discountPrice = meal['discount_price'] != null
        ? ((meal['discount_price'] is num)
              ? (meal['discount_price'] as num).toDouble()
              : double.tryParse(meal['discount_price'].toString()))
        : (meal['discountPrice'] != null
              ? ((meal['discountPrice'] is num)
                    ? (meal['discountPrice'] as num).toDouble()
                    : double.tryParse(meal['discountPrice'].toString()))
              : null);

    final int availableQty = meal['availableQty'] ?? 50;
    final int totalQty = meal['totalQty'] ?? 50;
    final bool isActive = meal['isActive'] ?? true;
    final bool isVeg = meal['isVeg'] ?? true;
    final String description = meal['description']?.toString() ?? '';
    final String? imageUrl =
        meal['image']?.toString() ?? meal['imageUrl']?.toString();

    return MealCardWidget(
      title: title,
      subtitleTag: "MEAL 1",
      imageUrl: imageUrl,
      price: price,
      discountPrice: discountPrice,
      taxPercentage: 5.0,
      description: description,
      isVeg: isVeg,
      isActive: isActive,
      currencySymbol: '£',
      availableQty: availableQty,
      totalQty: totalQty,
      onToggleActive: (_) async => await state.toggleTodayMealActive(title),
      onUpdate: () => _showEditTodayMealDialog(state, meal),
      onDelete: () => _confirmDelete(
        context,
        title: 'Remove Meal',
        message: 'Are you sure you want to remove "$title" from today\'s menu?',
        onConfirm: () async {
          await state.deleteTodayMeal(title);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('"$title" removed!')));
          }
        },
      ),
    );
  }

  // ─── TOMORROW MEAL CARD ───────────────────────────────────────────────────────
  Widget _buildTomorrowMealCard(
    RestaurantStateProvider state,
    Map<String, dynamic> meal,
    Color merchantGreen,
  ) {
    final String title = meal['title'] ?? meal['name'] ?? 'Special Dish';
    final double price = (meal['price'] is num)
        ? (meal['price'] as num).toDouble()
        : (double.tryParse(meal['price']?.toString() ?? '') ?? 0.0);

    final double? discountPrice = meal['discount_price'] != null
        ? ((meal['discount_price'] is num)
              ? (meal['discount_price'] as num).toDouble()
              : double.tryParse(meal['discount_price'].toString()))
        : (meal['discountPrice'] != null
              ? ((meal['discountPrice'] is num)
                    ? (meal['discountPrice'] as num).toDouble()
                    : double.tryParse(meal['discountPrice'].toString()))
              : null);

    final int availableQty = meal['availableQty'] ?? 50;
    final int totalQty = meal['totalQty'] ?? 50;
    final bool isActive = meal['isActive'] ?? true;
    final bool isVeg = meal['isVeg'] ?? true;
    final String description = meal['description']?.toString() ?? '';
    final String? imageUrl =
        meal['image']?.toString() ?? meal['imageUrl']?.toString();

    return MealCardWidget(
      title: title,
      subtitleTag: "TOMORROW'S MEAL",
      imageUrl: imageUrl,
      price: price,
      discountPrice: discountPrice,
      taxPercentage: 5.0,
      description: description,
      isVeg: isVeg,
      isActive: isActive,
      currencySymbol: '£',
      availableQty: availableQty,
      totalQty: totalQty,
      onToggleActive: (_) async => await state.toggleTomorrowMealActive(title),
      onUpdate: () => _showEditTomorrowMealDialog(state, meal),
      onDelete: () => _confirmDelete(
        context,
        title: 'Remove Meal',
        message: 'Remove "$title" from tomorrow\'s plan?',
        onConfirm: () async {
          await state.deleteTomorrowMeal(title);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('"$title" removed!')));
          }
        },
      ),
    );
  }

  // ─── ADD-ON CARD (horizontal) ─────────────────────────────────────────────────
  Widget _buildAddonCard(
    RestaurantStateProvider state,
    Map<String, dynamic> addon,
    Color merchantGreen,
  ) {
    final String title = addon['title'] ?? addon['name'] ?? 'Add-on Item';
    final double price = (addon['price'] is num)
        ? (addon['price'] as num).toDouble()
        : (double.tryParse(addon['price']?.toString() ?? '') ?? 0.0);
    final bool isVeg = addon['isVeg'] ?? true;
    final bool isActive = addon['isActive'] ?? true;
    final String? imageUrl =
        addon['image']?.toString() ?? addon['imageUrl']?.toString();

    return Container(
      width: 155,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Image with Veg Badge & Active Dot
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: FoodImage(
                  title: title,
                  imageUrl: imageUrl,
                  height: 105,
                  width: double.infinity,
                  borderRadius: 0,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: _buildVegIndicator(isVeg),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: isActive ? merchantGreen : const Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),

          // 2. Details & Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '£${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 10),

                // Edit & Delete Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showEditAddonDialog(state, addon),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: merchantGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00A859),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _confirmDelete(
                        context,
                        title: 'Remove Add-on',
                        message: 'Remove "$title" from add-ons?',
                        onConfirm: () async {
                          await state.deleteAddon(title);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Add-on "$title" removed!'),
                              ),
                            );
                          }
                        },
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ───────────────────────────────────────────────────────────
  Widget _buildVegIndicator(bool isVeg) {
    final Color color = isVeg
        ? const Color(0xFF00A859)
        : const Color(0xFF8B0000);
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

  Widget _buildDetailRow(
    String label,
    String val, {
    Color valueColor = const Color(0xFF374151),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ADD TODAY MEAL SCREEN NAVIGATION ─────────────────────────────────────────
  void _showAddTodayMealDialog(RestaurantStateProvider state) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddMenuItemScreen(
          stateProvider: state,
          initialMealType: "Today's Meal",
        ),
      ),
    );
    await state.fetchDailyMeals();
    if (mounted) {
      _tabController.animateTo(0);
    }
  }

  // ─── ADD TOMORROW MEAL SCREEN NAVIGATION ──────────────────────────────────────
  void _showAddTomorrowMealDialog(RestaurantStateProvider state) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddMenuItemScreen(
          stateProvider: state,
          initialMealType: "Tomorrow's Meal",
        ),
      ),
    );
    await state.fetchDailyMeals();
    if (mounted) {
      _tabController.animateTo(1);
    }
  }

  // ─── EDIT TODAY MEAL FULL SCREEN NAVIGATION ───────────────────────────────────
  void _showEditTodayMealDialog(
    RestaurantStateProvider state,
    Map<String, dynamic> meal,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddMenuItemScreen(
          stateProvider: state,
          initialMealType: "Today's Meal",
          existingMeal: meal,
          isEdit: true,
        ),
      ),
    );
    await state.fetchDailyMeals();
    if (mounted) {
      _tabController.animateTo(0);
    }
  }

  // ─── EDIT TOMORROW MEAL FULL SCREEN NAVIGATION ────────────────────────────────
  void _showEditTomorrowMealDialog(
    RestaurantStateProvider state,
    Map<String, dynamic> meal,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddMenuItemScreen(
          stateProvider: state,
          initialMealType: "Tomorrow's Meal",
          existingMeal: meal,
          isEdit: true,
        ),
      ),
    );
    await state.fetchDailyMeals();
    if (mounted) {
      _tabController.animateTo(1);
    }
  }

  // ─── ADD ADD-ON FULL SCREEN NAVIGATION ─────────────────────────────────────────
  void _showAddAddonDialog(RestaurantStateProvider state) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddAddonScreen(stateProvider: state),
      ),
    );
    await state.fetchMenuItems();
  }

  // ─── EDIT ADD-ON FULL SCREEN NAVIGATION ────────────────────────────────────────
  void _showEditAddonDialog(
    RestaurantStateProvider state,
    Map<String, dynamic> addon,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddAddonScreen(
          stateProvider: state,
          existingAddon: addon,
          isEdit: true,
        ),
      ),
    );
    await state.fetchMenuItems();
  }
}
