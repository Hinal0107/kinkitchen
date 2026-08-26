import 'package:flutter/material.dart';
import '../../../../core/widgets/food_image.dart';
import '../../../../models/menu_item.dart';
import 'dashboard_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color customerOrange = Color(0xFFFF5E00);
    const Color restaurantGreen = Color(0xFF00A859);

    // 1. Initial State: No Restaurant Selected yet
    if (state.selectedRestaurantId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Restaurant Menu', style: TextStyle(color: Color(0xFF1F2937))),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_outlined, size: 64, color: Color(0xFFD1D5DB)),
                const SizedBox(height: 16),
                const Text(
                  'No Restaurant Selected',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please select a restaurant from the Home tab to browse their kitchen menu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: customerOrange),
                  onPressed: () {
                    // Go to Home screen (tab index 0)
                    context.findAncestorStateOfType<DashboardScreenState>()?.setTab(0);
                  },
                  child: const Text('Browse Restaurants'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Loading State
    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: customerOrange),
        ),
      );
    }

    // 3. Error State
    if (state.errorMessage != null) {
      return Scaffold(
        body: Center(
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
                  style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: customerOrange),
                  onPressed: () => state.fetchRestaurantDetails(state.selectedRestaurantId!),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Access Control State: Free Trial Expired & No Active Subscription
    if (!state.canAccessMeals && state.activeSubscription == 'None') {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () {
              context.findAncestorStateOfType<DashboardScreenState>()?.setTab(0);
            },
          ),
          title: const Text('Menu Access Restricted', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: customerOrange.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_clock_outlined, size: 64, color: customerOrange),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Free Trial Expired',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your initial 7-day free trial period has ended.\nTo continue viewing meal menus and placing daily tiffin orders, please subscribe to a plan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Color(0xFF6B7280), height: 1.5),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customerOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    context.findAncestorStateOfType<DashboardScreenState>()?.setTab(2); // Go to Plans tab
                  },
                  icon: const Icon(Icons.card_membership_rounded, size: 20),
                  label: const Text('Browse Subscription Plans', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Build lists — exclude special categories (add-ons, today/tomorrow meals)
    final regularCategories = state.categories.where((cat) {
      final name = cat.name.toLowerCase();
      return !name.contains('add-on') &&
          !name.contains('addon') &&
          name != 'today' &&
          name != "today's meals" &&
          name != 'tomorrow' &&
          name != "tomorrow's meals";
    }).toList();

    final List<String> categoriesList = ['All', ...regularCategories.map((c) => c.name)];

    final filteredItems = state.menuItems.where((item) {
      // Exclude add-on and scheduled meal items
      final cat = state.categories.where((c) => c.id == item.categoryId).isNotEmpty
          ? state.categories.firstWhere((c) => c.id == item.categoryId)
          : null;
      if (cat != null) {
        final catName = cat.name.toLowerCase();
        if (catName.contains('add-on') || catName.contains('addon')) return false;
        if (catName == 'today' || catName == "today's meals") return false;
        if (catName == 'tomorrow' || catName == "tomorrow's meals") return false;
      }
      // Exclude items with a scheduleDate (today/tomorrow meals)
      if (item.scheduleDate != null && item.scheduleDate!.isNotEmpty) return false;

      final matchesCategory = state.selectedCategory == 'All' ||
          regularCategories.any((c) => c.name == state.selectedCategory && c.id == item.categoryId);
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () {
            // Clear selection and go back to home tab
            state.fetchRestaurants();
            context.findAncestorStateOfType<DashboardScreenState>()?.setTab(0);
          },
        ),
        title: const Text(
          'Menu',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search menu...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    fillColor: const Color(0xFFF3F4F6),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // 2. Category Chips
              if (regularCategories.isNotEmpty)
                Container(
                  height: 52,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: categoriesList.length,
                    itemBuilder: (context, index) {
                      final cat = categoriesList[index];
                      final isSelected = state.selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => state.setCategory(cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? customerOrange : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 3. Menu Items List / Empty States
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.restaurant_menu, size: 56, color: Color(0xFFD1D5DB)),
                              SizedBox(height: 16),
                              Text(
                                'No Menu Items Found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'This restaurant has not added any menu items yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: state.totalCartCount > 0 ? 80 : 16,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final MenuItem item = filteredItems[index];
                          final int qty = state.getItemQuantity(item.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FoodImage(title: item.name, imageUrl: item.imageUrl, width: 90, height: 90, borderRadius: 12),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _buildVegIndicator(item.vegType),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F4F6),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.vegType,
                                              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '₹${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: customerOrange),
                                          ),
                                          qty == 0
                                              ? SizedBox(
                                                  height: 32,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: customerOrange,
                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                    ),
                                                    onPressed: () {
                                                      state.addToCart(item);
                                                    },
                                                    child: const Text('Add', style: TextStyle(fontSize: 12)),
                                                  ),
                                                )
                                              : Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => state.removeFromCart(item),
                                                      child: const Icon(Icons.remove_circle, color: customerOrange, size: 24),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                      child: Text(
                                                        qty.toString(),
                                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => state.addToCart(item),
                                                      child: const Icon(Icons.add_circle, color: customerOrange, size: 24),
                                                    ),
                                                  ],
                                                ),
                                        ],
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

          // 4. Floating View Cart Banner
          if (state.totalCartCount > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () {
                  context.findAncestorStateOfType<DashboardScreenState>()?.setTab(3);
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: restaurantGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: restaurantGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${state.totalCartCount}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'View Cart',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '₹${state.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVegIndicator(String vegType) {
    final Color color = vegType == 'VEG' || vegType == 'JAIN' ? const Color(0xFF00A859) : const Color(0xFF8B0000);
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
