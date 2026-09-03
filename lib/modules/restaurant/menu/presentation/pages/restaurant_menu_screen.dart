import 'package:flutter/material.dart';
import 'package:kinkitchen/core/widgets/food_image.dart';
import 'package:kinkitchen/shared/models/menu_category.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';
import 'package:kinkitchen/modules/restaurant/restaurant_state_provider.dart';
import 'package:kinkitchen/modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';
import 'restaurant_add_menu_item_screen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  bool _hasFetchedData = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = RestaurantStateScope.of(context);
    if (!_hasFetchedData && !state.isLoading) {
      _hasFetchedData = true;
      if (state.menuItems.isEmpty) {
        Future.microtask(() {
          state.fetchCategories();
          state.fetchMenuItems();
        });
      }
    }
  }

  void _openAddMenuItemScreen(RestaurantStateProvider state, {MenuItem? existingItem}) async {
    Map<String, dynamic>? existingMealMap;
    if (existingItem != null) {
      existingMealMap = {
        'id': existingItem.id,
        'title': existingItem.name,
        'name': existingItem.name,
        'description': existingItem.description,
        'price': existingItem.price,
        'discount_price': existingItem.discountPrice,
        'veg_type': existingItem.vegType,
        'isVeg': existingItem.vegType == 'VEG' || existingItem.vegType == 'JAIN',
        'availability': existingItem.availability,
        'category_id': existingItem.categoryId,
        'image': existingItem.imageUrl,
        'imageUrl': existingItem.imageUrl,
      };
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddMenuItemScreen(
          stateProvider: state,
          existingMeal: existingMealMap,
          isEdit: existingItem != null,
        ),
      ),
    );
    await state.fetchMenuItems();
    await state.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final state = RestaurantStateScope.of(context);
    const Color merchantGreen = Color(0xFF00A859);

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search menu items...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              )
            : const Text(
                'Restaurant Menu',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: const Color(0xFF4B5563),
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: merchantGreen,
        foregroundColor: Colors.white,
        onPressed: () => _openAddMenuItemScreen(state),
        icon: const Icon(Icons.add),
        label: const Text('Add Menu Item'),
      ),
      body: _buildMenuItemsList(context, state, filteredMenuItems, merchantGreen),
    );
  }

  Widget _buildMenuItemsList(
    BuildContext context,
    RestaurantStateProvider state,
    List<MenuItem> items,
    Color merchantGreen,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0x0F00A859),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu_outlined,
                  size: 52,
                  color: Color(0xFF00A859),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _searchQuery.isNotEmpty ? 'No Items Matching "$_searchQuery"' : 'No Menu Items Added Yet',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the "+ Add Menu Item" button below to add dishes with pricing, category, veg/non-veg type, and photos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final bool isVeg = item.vegType.toUpperCase() == 'VEG' || item.vegType.toUpperCase() == 'JAIN';
        final bool isActive = item.availability;
        final categoryName = state.categories.firstWhere(
          (c) => c.id == item.categoryId,
          orElse: () => MenuCategory(id: 0, restaurantId: 0, name: 'General', description: '', status: 'ACTIVE'),
        ).name;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: const [
              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FoodImage(
                title: item.name,
                imageUrl: item.imageUrl,
                width: 80,
                height: 80,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            categoryName,
                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isVeg ? const Color(0x1A4CAF50) : const Color(0x1AF44336),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isVeg ? 'VEG' : 'NON-VEG',
                            style: TextStyle(
                              color: isVeg ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '£${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            ),
                            if (item.discountPrice > 0 && item.discountPrice < item.price) ...[
                              const SizedBox(width: 6),
                              Text(
                                '£${item.discountPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              activeColor: merchantGreen,
                              value: isActive,
                              onChanged: (val) {
                                state.updateMenuItem(item.id, {
                                  'name': item.name,
                                  'description': item.description,
                                  'price': item.price.toString(),
                                  'discount_price': item.discountPrice.toString(),
                                  'veg_type': item.vegType,
                                  'availability': val ? '1' : '0',
                                  'category_id': item.categoryId.toString(),
                                });
                              },
                            ),
                            GestureDetector(
                              onTap: () => _openAddMenuItemScreen(state, existingItem: item),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                margin: const EdgeInsets.only(right: 6),
                                child: const Icon(Icons.edit_outlined, color: Color(0xFF4B5563), size: 20),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _confirmDeleteMenuItem(context, state, item.id, item.name),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                              ),
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
    );
  }

  void _confirmDeleteMenuItem(
    BuildContext context,
    RestaurantStateProvider state,
    int id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await state.deleteMenuItem(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Menu item "$name" deleted!')),
                );
              }
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
}
