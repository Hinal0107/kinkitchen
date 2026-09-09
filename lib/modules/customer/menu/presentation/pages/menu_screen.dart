import 'package:flutter/material.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';
import 'package:kinkitchen/app/constants/api_constants.dart';
import 'package:kinkitchen/core/widgets/shimmer_loader.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasFetchedMenu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = TiffinStateScope.of(context);
    if (!_hasFetchedMenu) {
      _hasFetchedMenu = true;
      if (state.selectedRestaurantId != null && state.menuItems.isEmpty && !state.isLoading) {
        Future.microtask(() => state.fetchRestaurantMenu());
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color brandOrange = Color(0xFFFF5E00);
    const Color brandGreen = Color(0xFF00A859);

    // Filter menu items by selected category and search query
    final filteredMenuItems = state.menuItems.where((item) {
      // Category filter check
      if (state.selectedCategory.isNotEmpty &&
          state.selectedCategory != 'All' &&
          state.selectedCategory != 'All Items') {
        final selectedCat = state.categories.where((c) => c.name.toLowerCase() == state.selectedCategory.toLowerCase());
        if (selectedCat.isNotEmpty) {
          final catId = selectedCat.first.id;
          if (item.categoryId != catId && item.categoryId != 0) {
            return false;
          }
        }
      }

      // Search query check
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LOCATION',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined, color: brandOrange, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    state.selectedRestaurant != null
                        ? '${state.selectedRestaurant!.name}, ${state.selectedRestaurant!.city}'
                        : 'Current Location',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
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
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              if (state.unreadNotificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5E00),
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
          IconButton(
            tooltip: 'Refresh Menu',
            icon: Icon(Icons.refresh, color: brandOrange),
            onPressed: () => state.fetchRestaurantMenu(),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(context, state, filteredMenuItems),

          // Animated Floating Cart Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 20,
            right: 20,
            bottom: state.cartItems.isNotEmpty ? 16 : -70,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: state.cartItems.isNotEmpty ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: () {
                  context.findAncestorStateOfType<DashboardScreenState>()?.setTab(3); // Cart Tab
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: brandGreen,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4000A859),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${state.totalCartCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'View Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '£${state.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, TiffinStateProvider state, List<MenuItem> filteredMenuItems) {
    const Color brandOrange = Color(0xFFFF5E00);

    if (state.selectedRestaurantId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, size: 64, color: brandOrange),
              const SizedBox(height: 16),
              const Text(
                'Please Select a Kitchen First',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a kitchen to view its full interactive menu and pricing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => Navigator.pushNamed(context, '/restaurant-selection'),
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('Browse Kitchens', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isLoading) {
      return _buildMenuSkeleton();
    }

    return Column(
      children: [
        // Search Bar & Filter Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Search Input Box
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search meals...',
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Category Filter Chips Carousel (Fetched from GET /api/v1/restaurants/{restaurant_id}/categories)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(state, 'All Items'),
                    ...state.categories.map((cat) => _buildCategoryChip(state, cat.name)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Menu Items List matching Screen 2 design
        Expanded(
          child: filteredMenuItems.isEmpty
              ? _buildEmptyState(state)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: filteredMenuItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredMenuItems[index];
                    return _buildMenuItemCard(context, state, item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(TiffinStateProvider state, String categoryName) {
    const Color brandOrange = Color(0xFFFF5E00);
    final String currentCategory = state.selectedCategory.isEmpty ? 'All Items' : state.selectedCategory;
    final bool isSelected = currentCategory.toLowerCase() == categoryName.toLowerCase() ||
        (categoryName == 'All Items' && (currentCategory == 'All' || currentCategory == 'All Items'));

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(categoryName),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF374151),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        selectedColor: brandOrange,
        backgroundColor: const Color(0xFFF3F4F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        onSelected: (selected) {
          state.setCategory(categoryName == 'All Items' ? 'All' : categoryName);
        },
      ),
    );
  }

  // Menu Item Card matching Screen 2 in design image
  Widget _buildMenuItemCard(BuildContext context, TiffinStateProvider state, MenuItem item) {
    const Color brandOrange = Color(0xFFFF5E00);
    final imageUrl = ApiConfig.getFormattedImageUrl(item.imageUrl);
    final bool isVeg = item.vegType.toUpperCase() == 'VEG';
    final int qtyInCart = state.getItemQuantity(item.id, itemType: 'Menu Item');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Veg / Bestseller Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFFF3F4F6),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.fastfood, size: 44, color: brandOrange),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.fastfood, size: 44, color: brandOrange),
                        ),
                ),
              ),

              // Veg/Non-Veg Badge in top right corner
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: isVeg ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isVeg ? 'Veg' : 'Non-Veg',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isVeg ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Text(
                      '£${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3),
                  ),
                ],
                const SizedBox(height: 12),

                // Qty Counter or Add Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_fire_department_outlined, size: 14, color: Color(0xFF9CA3AF)),
                        SizedBox(width: 4),
                        Text(
                          'Freshly Prepared',
                          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),

                    if (qtyInCart > 0)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.remove, size: 16, color: Color(0xFF374151)),
                              onPressed: () {
                                state.removeFromCart(item, itemType: 'Menu Item');
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text(
                                '$qtyInCart',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.add, size: 16, color: brandOrange),
                              onPressed: () {
                                state.addToCart(item, itemType: 'Menu Item', quantity: 1);
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          state.addToCart(item, itemType: 'Menu Item', quantity: 1);
                        },
                        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildEmptyState(TiffinStateProvider state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_outlined, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No dishes matching "$_searchQuery"'
                  : 'No Menu Items Available',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching with a different keyword or category.'
                  : 'This kitchen has not added any dishes in this category yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ShimmerLoader.rectangular(width: double.infinity, height: 48, borderRadius: 12),
          const SizedBox(height: 16),
          Row(
            children: const [
              ShimmerLoader.rectangular(width: 80, height: 32, borderRadius: 16),
              SizedBox(width: 8),
              ShimmerLoader.rectangular(width: 90, height: 32, borderRadius: 16),
              SizedBox(width: 8),
              ShimmerLoader.rectangular(width: 85, height: 32, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 20),
          const ShimmerLoader.rectangular(width: double.infinity, height: 140, borderRadius: 16),
          const SizedBox(height: 14),
          const ShimmerLoader.rectangular(width: double.infinity, height: 140, borderRadius: 16),
          const SizedBox(height: 14),
          const ShimmerLoader.rectangular(width: double.infinity, height: 140, borderRadius: 16),
        ],
      ),
    );
  }
}
