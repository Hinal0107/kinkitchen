import 'package:flutter/material.dart';
import '../bloc/tiffin_state_provider.dart';
import 'dashboard_screen.dart';
import '../../../../models/menu_item.dart';
import '../../../../core/config/api_config.dart';

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
      if (state.selectedRestaurantId != null) {
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

    // Filter menu items by search query
    final filteredMenuItems = state.menuItems.where((item) {
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
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1F2937)),
            onPressed: () {},
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

          // Floating Cart Bar (Matching Screen 2 bottom green pill in design image)
          if (state.cartItems.isNotEmpty)
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
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
                        color: Color(0x3300A859),
                        blurRadius: 12,
                        offset: Offset(0, 4),
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
      return const Center(
        child: CircularProgressIndicator(color: brandOrange),
      );
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

              // Category Filter Chips Carousel
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(state, 'All Items'),
                    if (state.categories.isNotEmpty)
                      ...state.categories.map((cat) => _buildCategoryChip(state, cat.name))
                    else ...[
                      _buildCategoryChip(state, 'Main Meals'),
                      _buildCategoryChip(state, 'Sides'),
                      _buildCategoryChip(state, 'Desserts'),
                    ],
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
}
